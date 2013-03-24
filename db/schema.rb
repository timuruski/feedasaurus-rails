# encoding: UTF-8
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

ActiveRecord::Schema.define(:version => 20130312035024) do

  create_table "feeds", :force => true do |t|
    t.integer  "group_id"
    t.string   "title"
    t.string   "url"
    t.string   "site_url"
    t.string   "favicon"
    t.string   "username"
    t.string   "password"
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
    t.datetime "refresh_started_at"
    t.datetime "last_refreshed_at"
    t.datetime "response_updated_at"
    t.string   "response_etag"
    t.string   "response_status"
    t.datetime "next_refresh_at"
    t.integer  "refresh_every",       :default => 14400
    t.boolean  "enabled",             :default => true
  end

  create_table "groups", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "items", :force => true do |t|
    t.integer  "feed_id"
    t.string   "url",        :limit => 2048
    t.text     "title"
    t.text     "author"
    t.text     "content"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "fetched_at"
    t.datetime "read_at"
    t.datetime "starred_at"
  end

end
