class Flickr::Client

  # yet another Flickr API implementation?  sorry, couldn't help geeking out.

  @@config = YAML.load_file(File.join(::Rails.root.to_s, 'config', 'flickr.yml'))

  require 'net/http'

  attr_accessor :body, :doc, :response, :token, :frob, :verbose

  METHODS = {
    # users
    :user_info        => 'flickr.people.getInfo',
    :user_tags        => 'flickr.tags.getListUser',
    :user_photos      => 'flickr.urls.getUserPhotos',
    :user_sets        => 'flickr.photosets.getList',
    :user_blogs       => 'flickr.blogs.getList',      # authenticate
    :user_contacts    => 'flickr.contacts.getList',   # authenticate
    :user_favorites   => 'flickr.favorites.getPublicList',
    
    # photos
    :interesting      => 'flickr.interestingness.getList',
    :photo_info       => 'flickr.photos.getInfo',
    :photo_exif       => 'flickr.photos.getExif',
    :photo_sizes      => 'flickr.photos.getSizes',
    :photo_comments   => 'flickr.photos.comments.getList',
    :photo_search     => 'flickr.photos.search',
    
    # photosets
    :photoset_photos  => 'flickr.photosets.getPhotos',
    
    # auth
    :get_frob         => 'flickr.auth.getFrob',
    :get_token        => 'flickr.auth.getToken',
    
    # debug
    :fake             => 'fake'
  }

  SITE = "http://api.flickr.com/services/rest/"
  SITE_AUTH = "http://flickr.com/services/auth/"
  
  def api_key
    @@config['desktop_api_key']
  end
  
  def secret
    @@config['desktop_secret']
  end
  
  def library
    @@config['library']
  end
  
  def initialize(options=nil)
    @verbose = Toastflickr::Application::config.verbose
  end

  def get(method, params={})
  
    # http://api.flickr.com/services/rest/?method=flickr.photos.getInfo&api_key=xxx&photo_id=xxxx
    # http://api.flickr.com/services/rest/?method=flickr.test.echo&name=value
  
    # get Flickr API command name
    params[:method] = METHODS[method]
    
    # if there's an :auth_token, generate the :api_sig
    if params[:auth_token]
      params[:api_sig] = make_api_sig('auth_token' => params[:auth_token], 'method' => params[:method])
    end
    
    url = SITE + "?" + hash_to_query(params)

    begin
      puts ["get #{method}", params.inspect].join("\t") if @verbose
      @response = Net::HTTP.get_response(URI.parse(url))
    
      case
      # parse body
      when @response.kind_of?(Net::HTTPSuccess)
        @body = @response.body
        @doc = Nokogiri::XML(@body)
      else
        raise "ERROR: #{@response.class.to_s}: #{url}"
      end

    rescue
      puts "ERROR: #{$!}"
    end
    
    if @doc.at('rsp/err')
      msg = @doc.at('rsp/err').attribute('msg').text
      code = @doc.at('rsp/err').attribute('code').text
      raise Flickr::ServerError, "#{msg} (#{code})"
    end
    @body
  end

  def web_auth(perms = 'write')
    # http://www.flickr.com/services/api/auth.howto.web.html
    # 1) make login link
    api_sig = make_api_sig('perms' => perms)
    params = {:perms => perms, :api_sig => api_sig}
    url = SITE_AUTH + "?" + hash_to_query(params)
  end
  
  # TO AUTHORIZE: 
  # 1) run "desktop_auth_link" to retrieve a frob and generate an authorization link
  # 2) click link to authorize
  # 3) run "get token" and save new token to User
  def desktop_auth_link(perms = 'write')
    # http://www.flickr.com/services/api/auth.howto.desktop.html
    get_frob
    api_sig = make_api_sig('frob' => @frob, 'perms' => perms)
    params = {:perms => perms, :api_sig => api_sig, :frob => @frob}
    url = SITE_AUTH + "?" + hash_to_query(params)
  end

  # get a new frob that will be unique to this user
  def get_frob
    api_sig = make_api_sig('method' => METHODS[:get_frob])
    get :get_frob, :api_sig => api_sig
    @frob = @doc.at('rsp/frob').text
  end

  # get a token derived from the user's frob
  def get_token(frob)
    # http://www.flickr.com/services/api/auth.howto.desktop.html
    api_sig = make_api_sig('frob' => frob, 'method' => METHODS[:get_token])
    get :get_token, :api_sig => api_sig, :frob => frob
    @token = @doc.at('/rsp/auth/token').text
  end
  
  def get_info(user_id)
    get :user_info, :user_id => user_id
    p = @doc.at('rsp/person')
    {
      :username =>        p.at('username').text,
      :realname =>        p.at('realname').text,
      :url =>             p.at('photosurl').text
    }
  end
  
  def get_tags(user_id)
    get :user_tags, :user_id => user_id
    @doc.css('rsp/who/tags/tag').map{|t| t.text}
  end

  def get_sets(user_id,&block)
    get :user_sets, :user_id => user_id
    @doc.css('rsp/photosets/photoset').each do |set|
      a = {
        :id =>                  set.attribute('id').text,
        :title =>               set.at('title').text,
        :description =>         set.at('description').text,
        :primary =>             set.attribute('primary').text
      }
      yield a
    end
  end
  
  def get_photos(photoset_id,&block)
    get :photoset_photos, :photoset_id => photoset_id
    @doc.css('rsp/photoset/photo').each do |p|
      a = {
        :id =>                  p.attribute('id').text,
        :farm =>                p.attribute('farm').text,
        :server =>              p.attribute('server').text,
        :secret =>              p.attribute('secret').text,
        :title =>               p.attribute('title').text,
        :primary =>             p.attribute('isprimary').text.to_i > 0 ? true : false
      }
      yield a
    end
  end
  
  def get_photo_info(photo_id)
    get :photo_info, :photo_id => photo_id
    photo = @doc.at('/rsp/photo')
    {
      :url =>             photo.css('urls/url[@type="photopage"]').text,
      :title =>           photo.css('title').text,
      :flickr_user_id =>  photo.css('owner').attribute('nsid').text,
      :username =>        photo.css('owner').attribute('username').text,
      :tags =>            photo.css('tags/tag').map{|t| t.text}.join(" "),
      :farm =>            photo.attribute('farm').text,
      :server =>          photo.attribute('server').text,
      :secret =>          photo.attribute('secret').text,
      :originalsecret =>  photo.attribute('originalsecret').text,
      :originalformat =>  photo.attribute('originalformat').text,
      :posted =>          Time.at(photo.attribute('dateuploaded').text.to_i),
      :taken =>           Time.parse(photo.css('dates').attribute('taken').text),
    }
  end
  
  def get_exif(photo_id)
    get :photo_exif, :photo_id => photo_id
    photo = @doc.at('/rsp/photo')
    {
      :camera =>          photo.css('exif[@label="Model"]/raw').text,
      :exposure =>        photo.css('exif[@label="Exposure"]/clean').text,
      :aperture =>        photo.css('exif[@label="Aperture"]/clean').text,
      :iso =>             photo.css('exif[@label="ISO Speed"]/raw').text,
      :length =>          photo.css('exif[@label="Focal Length"]/clean').text
    }
  end
  
  def get_photo_comments(photo_id,&block)
    get :photo_comments, :photo_id => photo_id
    @doc.css('rsp/comments/comment').each do |c|
      a = {
        :flickr_comment_id =>   c.attribute('id').text,
        :url =>                 c.attribute('permalink').text,
        :authorname =>          c.attribute('authorname').text,
        :flickr_user_id =>      c.attribute('author').text,
        :comment =>             c.text,
        :added =>               Time.at(c.attribute('datecreate').text.to_i)
      }
      yield a
    end
  end
  
  def get_contacts(token,&block)
    get :user_contacts, :auth_token => token
    @doc.css('rsp/contacts/contact').each do |c|
      a = {
        :id =>          c.attribute('nsid').text,
        :username =>    c.attribute('username').text,
        :realname =>    c.attribute('realname').text,
        :iconserver =>  c.attribute('iconserver').text,
        :iconfarm =>    c.attribute('iconfarm').text,
        :ignored =>     c.attribute('ignored').text,
        :friend =>      c.attribute('friend').text,
        :family =>      c.attribute('family').text,
        :path_alias =>  c.attribute('path_alias').text,
        :location =>    c.attribute('location').text
      }
      yield a
    end
  end
  
  def get_blogs(token)
    get :user_blogs, :auth_token => token
    @doc.css('rsp/TODO').each do |b|
      a = {
        :id =>      b.attribute('????').text
      }
      yield a
    end
  end
  
  def get_url(user_id)
    get :user_photos, :user_id => user_id
    @doc.at('rsp/user').attribute('url').text
  end
  
  def get_search(options,&block)
    get :photo_search, options
    parse_photos(&block)
  end
  
  # get all favorites for a user
  def get_favorites(user_id,&block)
    get :user_favorites, :user_id => user_id
    parse_photos(&block)
  end
  
  def parse_photos(&block)
    @doc.css('rsp/photos/photo').each do |f|
      a = {
        :id =>                  f.attribute('id').text,
        :owner =>               f.attribute('owner').text,
        :server =>              f.attribute('server').text,
        :secret =>              f.attribute('secret').text,
        :title =>               f.attribute('title').text,
        :ispublic =>            f.attribute('ispublic').text,
        :isfriend =>            f.attribute('isfriend').text,
        :isfamily =>            f.attribute('isfamily').text
      }
      yield a
    end
  end

  def make_api_sig(values)
    values.merge!('api_key' => api_key)
    api_string = values.sort{|a,b| a[0] <=> b[0]}.flatten.unshift(secret).join('')
    Digest::MD5.hexdigest(api_string)
  end
  
  private

  # convert the hash of field/value pairs into a FileMaker query string
  def hash_to_query(params)
    q = []
    params.merge!(:api_key => api_key)
    params.each do |query_field,value|
      query_field = CGI.escape(query_field.to_s)
      query_value = CGI.escape(value.to_s)
      q << "#{query_field}=#{query_value}"
    end
    q.length > 0 ? q.join('&') : ''
  end

end


class Flickr::ServerError < RuntimeError
# attr :okToRetry
# def initialize(okToRetry)
#   @okToRetry = okToRetry
# end
end