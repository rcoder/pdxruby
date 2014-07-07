# This file is auto-generated from the current state of the database. Instead of editing this file,
# please use the migrations feature of ActiveRecord to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 7) do

  create_table "articles", :force => true do |t|
    t.integer  "member_id"
    t.datetime "modified_at"
    t.string   "title",        :limit => 256
    t.text     "content"
    t.string   "link",         :limit => 256
    t.string   "content_hash", :limit => 32
  end

  add_index "articles", ["link"], :name => "index_articles_on_link"

  create_table "events", :force => true do |t|
    t.integer  "member_id"
    t.integer  "location_id"
    t.string   "name",        :limit => 64
    t.datetime "starts_at"
    t.datetime "ends_at"
    t.text     "agenda"
    t.string   "status",      :limit => 32
    t.text     "minutes"
    t.datetime "created_at"
  end

  create_table "feedbacks", :force => true do |t|
    t.integer  "participant_id"
    t.text     "feedback"
    t.datetime "created_at"
  end

  create_table "locations", :force => true do |t|
    t.string   "name",       :limit => 64
    t.text     "address"
    t.string   "homepage",   :limit => 256
    t.datetime "created_at"
  end

  create_table "members", :force => true do |t|
    t.string   "name",           :limit => 128
    t.string   "email",          :limit => 128
    t.string   "feed_url",       :limit => 256
    t.text     "about"
    t.datetime "created_at"
    t.string   "password",       :limit => 40
    t.string   "password_reset", :limit => 40
    t.string   "irc_nick",       :limit => 128
  end

  create_table "participants", :force => true do |t|
    t.integer  "member_id"
    t.integer  "event_id"
    t.string   "attending",  :limit => 32
    t.text     "comments"
    t.datetime "created_at"
  end

end
