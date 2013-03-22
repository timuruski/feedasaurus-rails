class CreateRawFeeds < ActiveRecord::Migration
  def change
    create_table :raw_feeds do |t|
      t.timestamps

      t.references :feed
      t.string     :url

      # Response stuff
      t.integer  :status
      t.string   :etag
      t.datetime :last_modified
      t.text     :headers
    end
  end
end
