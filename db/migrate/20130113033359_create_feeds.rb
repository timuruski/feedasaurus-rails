class CreateFeeds < ActiveRecord::Migration
  def change
    create_table :feeds do |t|
      t.references :group

      t.string :title
      t.string :feed_url
      t.string :site_url
      t.string :favicon
      t.datetime :refreshed_at

      t.timestamps
    end
  end
end
