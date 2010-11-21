class CreatePhotos < ActiveRecord::Migration
  def self.up
    create_table :photos do |t|
      t.integer :flickr_photo_id
      t.string :tags
      t.string :title
      t.text :description
      t.datetime :taken
      t.datetime :posted
      t.string :url
      t.string :flickr_user_id
      t.datetime :created_at
      t.datetime :updated_at
      t.integer :user_id
      t.string :secret
      t.string :server
      t.string :originalsecret
      t.string :originalformat
      t.string :farm
      t.string :username
      t.string :camera
      t.string :exposure
      t.string :aperture
      t.integer :iso
      t.string :length

      t.timestamps
    end
  end

  def self.down
    drop_table :photos
  end
end
