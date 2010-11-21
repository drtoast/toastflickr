class Photo < ActiveRecord::Base
  belongs_to :user
  has_many :comments
  has_many :photoset_photos
    has_many :photosets, :through => :photoset_photos
  
  attr_accessor :client
  
  after_initialize :initialize_client

  def initialize_client
    @client = Flickr::Client.new
  end
  
  def Photo.search(options,&block)
    client = Flickr::Client.new
    client.get_search(options,&block)
  end
  
  # only get data we haven't grabbed before, unless force is true
  def get_all(force=false)
    get_info(force)
    get_exif(force)
    get_comments
    get_square
    get_original
  end
  
  # get and save metadata for this photo: url, title,etc
  def get_info(force=false)
    return unless force || url.blank?
    info = @client.get_photo_info(flickr_photo_id)
    update_attributes(info)
  end
  
  # get and save EXIF data for this photo: camera, aperture, exposure, iso, length
  def get_exif(force=false)
    return unless force || camera.blank?
    exif = @client.get_exif(flickr_photo_id)
    update_attributes(exif)
  end
  
  # get and update comments
  def get_comments
    @client.get_photo_comments(flickr_photo_id) do |c|
      comment = comments.find_or_initialize_by_flickr_comment_id(c[:flickr_comment_id])
      comment.update_attributes(c)
    end
  end
  
  # URLs
  def square
    "http://farm#{farm}.static.flickr.com/#{server}/#{flickr_photo_id}_#{secret}_s.jpg"
  end
  
  def square_local
    "#{@client.library}/#{flickr_user_id}/square/#{flickr_photo_id}.jpg"
  end
  
  def thumbnail
    "http://farm#{farm}.static.flickr.com/#{server}/#{flickr_photo_id}_#{secret}_t.jpg"
  end
  
  def small
    "http://farm#{farm}.static.flickr.com/#{server}/#{flickr_photo_id}_#{secret}_m.jpg"
  end
  
  def medium
    "http://farm#{farm}.static.flickr.com/#{server}/#{flickr_photo_id}_#{secret}.jpg"
  end
  
  def large
    "http://farm#{farm}.static.flickr.com/#{server}/#{flickr_photo_id}_#{secret}_b.jpg"
  end
  
  def original
    "http://farm#{farm}.static.flickr.com/#{server}/#{flickr_photo_id}_#{originalsecret}_o.#{originalformat}"
  end
  
  def original_local
    "#{@client.library}/#{flickr_user_id}/original/#{flickr_photo_id}.#{originalformat}"
  end
  
  # download the small square image
  def get_square
    grab(square, square_local)
  end
  
  # download the original image
  def get_original
    grab(original, original_local)
  end
  
  def grab(url, local)
    begin
      return local if File.exists?(local)
      puts "grabbing #{url}" if @client.verbose
      @response = Net::HTTP.get_response(URI.parse(url))
      puts "\t#{@response.class}" if @client.verbose
    
      case 
      # parse body
      when @response.kind_of?(Net::HTTPSuccess)
        dir = File.dirname(local)
        FileUtils.mkdir_p(dir) unless File.directory?(dir)
        open(local, "wb") do |f|
          f.write(@response.body)
        end
      else
        puts "ERROR: #{@response.class.to_s}: #{url}"
      end

    rescue => e
      puts "ERROR: #{e}"
    end
    return local
  end
  
end
