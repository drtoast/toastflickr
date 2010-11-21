class User < ActiveRecord::Base
  
  has_many :photos
  has_many :photosets
  
  attr_accessor :client
  
  after_initialize :initialize_client
  
  def initialize_client
    @client = Flickr::Client.new
  end
  
  # update database fields and download all photos in all sets
  def get_all(force=false)
    get_info(force)
    # get_tags
    get_sets
    reload
    photosets.each do |s|
      # get farm, server, secret, and primary
      s.get_photos
    end
    Photo.all.each do |p|
      p.get_info(force)       # url, title, taken, posted, etc
      p.get_exif(force)       # camera, iso, exposure, length, etc
      p.get_comments
      p.get_square
      p.get_original
    end
    true
  end
  
  # return the link to authorize Flickr, and save the temporary frob in "token"
  def get_auth_link
    link = @client.desktop_auth_link
    self.token = @client.frob
    save
    return link
  end
  
  # send the frob to flickr, then save the auth token in "token"
  def get_token
    self.token = @client.get_token(token)
    save
  end
  
  # get info on a person
  def get_info(force=false)
    return unless force || username.blank?
    info = @client.get_info(flickr_user_id)
    update_attributes(info)
  end
  
  # return tags as an array (TODO: save?)
  def get_tags
    @client.get_tags(flickr_user_id)
  end
  
  # get all photosets for a user
  def get_sets
    @client.get_sets(flickr_user_id) do |set|
      photoset = photosets.find_or_initialize_by_flickr_photoset_id(set[:id])
      photoset.update_attributes(set)
    end
  end
  
  # get all favorites for a user
  def get_favorites
    @client.get_favorites(flickr_user_id) do |favorite|
      # TODO: something more interesting
      puts favorite.inspect
    end
  end
  
  # get all blogs for a user
  def get_blogs
    @client.get_blogs(token)
  end
  
  # get all contacts for a user
  def get_contacts(&block)
    @client.get_contacts(token) do |contact|
      puts contact.inspect
    end
  end
  
  # get url for the user's photos
  def get_url
    @client.get_url(flickr_user_id)
  end



  ### misc. silliness
  
  # return a chromatically sorted array of all images with a color tag
  def colors
    results = []
    ['red','orange','yellow','green','blue','purple'].each do |color|
      Photo.search(:tags => color, :user_id => flickr_user_id) do |p|
        results << p
        puts p.inspect if @client.verbose
      end
    end
    results
  end
end
