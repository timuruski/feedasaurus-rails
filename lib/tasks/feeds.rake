require_relative '../../config/environment'

namespace :feeds do

  desc "Start worker to periodically refresh feeds"
  task :worker do
    worker_out = STDOUT
    worker_out.sync = true

    worker = Worker.new(worker_out)
    trap('TERM') { worker.stop }
    trap('INT') { exit }

    worker.start
  end

  desc "Import feeds from OPML"
  task :import, :file do |t, args|
    file = File.open(args[:file], 'r')
    FeedImporter.import(file) do |f|
      puts %Q{Importing "#{f.title}"}
    end
  end

  desc "List all feeds"
  task :list do
    Feed.find_each do |f|
      puts "#{f.id}: #{f.title} - #{f.last_refreshed_at? ? f.last_refreshed_at.strftime('%c') : 'Never'}"
    end
  end

  desc "Search for a feed by title"
  task :search, :query do |t, args|
    Feed.search(args[:query]).find_each do |f|
      puts "#{f.id}: #{f.title} - #{f.last_refreshed_at? ? f.last_refreshed_at.strftime('%c') : 'Never'}"
    end
  end

  desc "Refresh the items in a feed"
  task :refresh, :feed_id do |t, args|
    feed = Feed.find(args[:feed_id])
    feed.refresh!
  end

  desc "Refresh all feeds"
  task :refresh_all do
    Feed.find_each do |feed|
      puts "Refreshing #{feed.title}..."
      feed.refresh!
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
