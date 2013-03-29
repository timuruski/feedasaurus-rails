require 'rss'
require 'feed_fetcher'
require 'item_builder'

class FeedRefresher < Struct.new(:feed)
  def self.refresh(feed)
    new(feed).refresh
  end

  def refresh
    request = fetch_feed
    request.save

    create_items(request) if request.new_body?

    feed
  rescue
    raise Error, %Q(Error refreshing feed #{feed.id} "#{feed.title}")
  end


  class Error < RuntimeError
    def initialize(message, original = $!)
      super(message)
      @original = original
    end

    attr_reader :original
    def original_message; original.message end
    def original_backtrace; original.backtrace end
  end


  protected


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
