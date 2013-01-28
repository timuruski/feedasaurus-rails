class CreateFeeds < ActiveRecord::Migration
  def change
    create_table :feeds do |t|
      t.references :group

      t.string :title
      t.string :url
      t.string :site_url
      t.string :favicon

      t.string :username
      t.string :password

      t.timestamps

      # Refreshing
      t.datetime :refresh_started_at
      t.datetime :refreshed_at
      t.datetime :response_updated_at
      t.string   :response_etag
      t.string   :response_status
    end
  end
end
