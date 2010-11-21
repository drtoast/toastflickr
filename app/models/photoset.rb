class Photoset < ActiveRecord::Base
  
  belongs_to :user
  has_many :photoset_photos
    has_many :photos, :through => :photoset_photos
  
  attr_accessor :client, :verbose

  after_initialize :initialize_client
  
  def initialize_client
    @client = Flickr::Client.new
  end

  # get farm, server, secret, and primary
  def get_photos
    @client.get_photos(flickr_photoset_id) do |p|
      photo = Photo.find_or_create_by_flickr_photo_id(p[:id])
      photo.update_attributes(:farm => p[:farm], :server => p[:server], :secret => p[:secret])
      photo.save
      set_photo = photoset_photos.find_or_initialize_by_photo_id(photo.id)
      set_photo.update_attributes(:primary => p[:primary])
    end
  end
  
  def thumbnail
    p = Photo.find_by_flickr_photo_id(primary)
    p.square
  end

end
