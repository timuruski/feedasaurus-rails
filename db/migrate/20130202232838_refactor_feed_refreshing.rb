class RefactorFeedRefreshing < ActiveRecord::Migration
  def change
    rename_column :feeds, :refreshed_at, :last_refreshed_at
    add_column :feeds, :next_refresh_at, :datetime, :null => true
    add_column :feeds, :refresh_every, :integer, :default => 4.hours.to_i
  end
end
