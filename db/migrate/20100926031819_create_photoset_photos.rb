class CreatePhotosetPhotos < ActiveRecord::Migration
  def self.up
    create_table :photoset_photos do |t|
      t.integer :photo_id
      t.integer :photoset_id

      t.timestamps
    end
  end

  def self.down
    drop_table :photoset_photos
  end
end
