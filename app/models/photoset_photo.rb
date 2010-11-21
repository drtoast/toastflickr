class PhotosetPhoto < ActiveRecord::Base
  belongs_to :photoset
  belongs_to :photo
end
