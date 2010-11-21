class CreatePhotosets < ActiveRecord::Migration
  def self.up
    create_table :photosets do |t|
      t.integer :id
      t.string :flickr_photoset_id
      t.integer :user_id
      t.string :title
      t.text :description
      t.integer :primary
      t.datetime :created_at
      t.datetime :updated_at

      t.timestamps
    end
  end

  def self.down
    drop_table :photosets
  end
end
