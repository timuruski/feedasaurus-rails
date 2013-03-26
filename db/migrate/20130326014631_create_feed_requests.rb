class CreateFeedRequests < ActiveRecord::Migration
  def change
    create_table :feed_requests do |table|
      table.datetime :created_at,    null: false
      table.integer  :status,        null: false
      table.string   :etag,          null: true
      table.datetime :last_modified, null: true
      table.text     :headers,       null: true
    end
  end
end
