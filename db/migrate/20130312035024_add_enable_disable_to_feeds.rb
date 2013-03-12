class AddEnableDisableToFeeds < ActiveRecord::Migration
  def change
    add_column :feeds, :enabled, :boolean, :default => true
  end
end
