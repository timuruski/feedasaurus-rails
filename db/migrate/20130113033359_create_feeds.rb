class CreateFeeds < ActiveRecord::Migration
  def change
    create_table :feeds do |t|
      t.references :group

      t.string :title
      t.string :url
      t.string :site_url
      t.string :favicon
      t.boolean :enabled, :default => true

      # Not really in use yet
      t.string :username
      t.string :password

      t.timestamps

      # Refreshing
      t.datetime :refresh_started_at
      t.datetime :refreshed_at

      # Raw feed details
      t.integer  :raw_feed_status
      t.string   :raw_feed_etag
      t.datetime :raw_feed_last_modified
      t.text     :raw_feed_headers
    end
  end
end
