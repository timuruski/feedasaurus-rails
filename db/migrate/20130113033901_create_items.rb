class CreateItems < ActiveRecord::Migration
  def change
    create_table :items do |t|
      t.references :feed

      t.string :url, :limit => 2048
      t.text :title
      t.text :author
      t.text :content
      t.datetime :published_at
      t.datetime :fetched_at
      t.datetime :read_at
      t.datetime :starred_at

      t.timestamps
    end
  end
end
