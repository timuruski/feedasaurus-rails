namespace :feeds do

  def describe_feed(feed)
    if feed.last_refreshed_at
      last_refreshed = "last refreshed at #{feed.last_refreshed_at.asctime}"
    else
      last_refreshed = 'never refreshed'
    end

    %Q(#{feed.id} "#{feed.title}" #{last_refreshed})
  end

  def refresh_and_capture_error(feed)
    puts "Refreshing feed #{describe_feed(feed)}"
    feed.refresh!
  rescue FeedRefresher::Error => error
    puts error.message
    puts error.original_message
    puts *error.original_backtrace
  end

  desc "Start worker to periodically refresh feeds"
  task :worker => :environment do
    worker_out = STDOUT
    worker_out.sync = true

    worker = Worker.new(worker_out)
    trap('TERM') { worker.stop }
    trap('INT') { exit }

    worker.start
  end

  desc "Import feeds from OPML"
  task :import, [:file] => :environment do |t, args|
    file = File.open(args[:file], 'r')
    FeedImporter.import(file) do |f|
      puts %Q{Importing "#{f.title}"}
    end

    file.close
  end

  desc "List all feeds"
  task :list => :environment do
    Feed.find_each do |f|
      puts describe_feed(f)
    end
  end

  desc "Search for a feed by title"
  task :search, [:query] => :environment do |t, args|
    Feed.search(args[:query]).find_each do |f|
      puts describe_feed(f)
    end
  end

  desc "Refresh the items in a feed"
  task :refresh, [:feed_id] => :environment do |t, args|
    feed = Feed.find(args[:feed_id])
    refresh_and_capture_error(feed)
  end

  desc "Refresh all feeds (requires worker)"
  task :refresh_all => :environment do
    Feed.find_each do |feed|
      feed.schedule_refresh
    end
  end

  desc "Refresh all feeds immediately (synchronous, no worker)"
  task :refresh_all_now => :environment do
    stop_refresh = false
    trap('TERM') { stop_refresh = true }
    trap('INT') { stop_refresh = true }

    puts "Refreshing all feeds (^C to stop)\n---"

    Feed.find_each do |feed|
      puts "Stopping..." and break if stop_refresh
      refresh_and_capture_error(feed)
    end
  end

  desc "Reset a feed"
  task :reset, [:feed_id] => :environment do |t, args|
    feed = Feed.find(args[:feed_id])
    feed.reset
  end

  desc "Reset all feeds"
  task :reset_all => :environment do
    Feed.find_each do |feed|
      feed.reset
    end
  end

  desc "Purge all feeds"
  task :purge => :environment do
    Feed.destroy_all
  end

end
