require 'rss'
require 'feed_fetcher'
require 'item_builder'

class FeedRefresher < Struct.new(:feed)
  def self.refresh(feed)
    new(feed).refresh
  end

  def refresh
    request = fetch_feed
    create_items(request) if request.new_body?
    request.save

    feed
  end

  def fetch_feed
    request = feed.build_request
    FeedFetcher.fetch(request)
  end

  def create_items(request)
    items = parse_items(request).items
    items.each do |item_rss|
      create_item(item_rss)
    end
  end

  def parse_items(request)
    RSS::Parser.parse(request.body)
  end

  def create_item(item_rss)
    item = ItemBuilder.build(item_rss)
    return if item_exists?(item)

    item.feed = feed
    item.fetched_at = Time.current
    item.save
  end

  def item_exists?(item_rss)
    feed.items.where(url: item_rss.url).exists?
  end

end
