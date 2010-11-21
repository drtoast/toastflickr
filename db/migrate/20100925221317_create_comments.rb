class CreateComments < ActiveRecord::Migration
  def self.up
    create_table :comments do |t|
      t.integer :id
      t.integer :flickr_photo_id
      t.string :flickr_user_id
      t.string :authorname
      t.datetime :added
      t.string :url
      t.text :comment
      t.string :flickr_comment_id
      t.integer :photo_id
      t.datetime :created_at
      t.datetime :updated_at

      t.timestamps
    end
  end

  def self.down
    drop_table :comments
  end
end
