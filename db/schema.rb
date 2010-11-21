# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20100926055322) do

  create_table "comments", :force => true do |t|
    t.integer  "flickr_photo_id"
    t.string   "flickr_user_id"
    t.string   "authorname"
    t.datetime "added"
    t.string   "url"
    t.text     "comment"
    t.string   "flickr_comment_id"
    t.integer  "photo_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "photos", :force => true do |t|
    t.integer  "flickr_photo_id"
    t.string   "tags"
    t.string   "title"
    t.text     "description"
    t.datetime "taken"
    t.datetime "posted"
    t.string   "url"
    t.string   "flickr_user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.string   "secret"
    t.string   "server"
    t.string   "originalsecret"
    t.string   "originalformat"
    t.string   "farm"
    t.string   "username"
    t.string   "camera"
    t.string   "exposure"
    t.string   "aperture"
    t.integer  "iso"
    t.string   "length"
  end

  create_table "photoset_photos", :force => true do |t|
    t.integer  "photo_id"
    t.integer  "photoset_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "primary"
  end

  create_table "photosets", :force => true do |t|
    t.string   "flickr_photoset_id"
    t.integer  "user_id"
    t.string   "title"
    t.text     "description"
    t.integer  "primary"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "token"
    t.string   "username"
    t.string   "realname"
    t.string   "url"
    t.string   "flickr_user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
