require_relative '../../config/environment'

task :loadpath do
  puts $:
end

namespace :feeds do

  desc "Import feeds from OPML"
  task :import, :opml do |t, args|
    opml = File.read(args[:opml])
    xml = Nokogiri.parse(opml)
    xml.xpath("//outline[@type='rss']")
      .map { |e| { url: e['xmlUrl'], title: e['title'] } }
      .reject { |fx| Feed.where(feed_url: fx[:url]).exists? }
      .each do |fx|
        Feed.create do |f|
          f.title = fx[:title]
          f.feed_url = fx[:url]
        end
      end
  end

  desc "List all feeds"
  task :list do
    Feed.find_each do |f|
      puts "#{f.id}: #{f.title} - #{f.refreshed_at? ? f.refreshed_at.strftime('%c') : 'Never'}"
    end
  end

  desc "Refresh the items in a feed"
  task :refresh, :feed_id do |t, args|
    feed = Feed.find(args[:feed_id])
    Refresher.new(feed).refresh!
  end

  desc "Refresh all feeds"
  task :refresh_all do
    Feed.find_each do |feed|
      puts "Refreshing #{feed.title}..."
      Refresher.new(feed).refresh!
    end
  end

  desc "Purge all feeds"
  task :purge do
    Feed.destroy_all
  end

end
