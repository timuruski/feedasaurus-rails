require_relative '../../config/environment'

task :loadpath do
  puts $:
end

namespace :feeds do

  desc "Import feeds from OPML"
  task :import, :file do |t, args|
    file = File.open(args[:file], 'r')
    Importer.import(file) do |f|
      puts %Q{Importing "#{f.title}"}
    end
  end

  desc "List all feeds"
  task :list do
    Feed.find_each do |f|
      puts "#{f.id}: #{f.title} - #{f.refreshed_at? ? f.refreshed_at.strftime('%c') : 'Never'}"
    end
  end

  desc "Search for a feed by title"
  task :search, :query do |t, args|
    Feed.search(args[:query]).find_each do |f|
      puts "#{f.id}: #{f.title} - #{f.refreshed_at? ? f.refreshed_at.strftime('%c') : 'Never'}"
    end
  end

  desc "Refresh the items in a feed"
  task :refresh, :feed_id do |t, args|
    feed = Feed.find(args[:feed_id])
    Refresher.refresh(feed)
  end

  desc "Refresh all feeds"
  task :refresh_all do
    Feed.find_each do |feed|
      puts "Refreshing #{feed.title}..."
      Refresher.refresh(feed)
    end
  end

  desc "Reset a feed"
  task :reset, :feed_id do |t, args|
    feed = Feed.find(args[:feed_id])
    feed.reset
  end

  desc "Reset all feeds"
  task :reset_all do
    Feed.find_each do |feed|
      feed.reset
    end
  end

  desc "Purge all feeds"
  task :purge do
    Feed.destroy_all
  end

end
