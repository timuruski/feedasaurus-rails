require 'rss'
require 'feed_fetcher'
require 'item_builder'

class FeedRefresher < Struct.new(:feed)
  def self.refresh(feed)
    new(feed).refresh
  end

  def refresh
    request = fetch_feed
    create_items(request)
    persist_request(request)

    feed
  end

  def fetch_feed
    initial_request = feed.last_successful_request
    FeedFetcher.fetch(initial_request)
  end

  def create_items(request)
    items = parse_items(request)
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

  def persist_request(request)
    feed.requests << request
    request.save
  end

end
