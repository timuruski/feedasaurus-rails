require 'rss'

class Refresher
  def initialize(feed)
    @feed = feed
  end

  attr_reader :feed

  def refresh!
    feed.items.destroy_all
    refresh
  end

  def refresh
    items.each do |item_rss|
      create_item(item_rss)
    end

    feed.update_attribute(:refreshed_at, Time.current)
    feed
  end

  def create_item(item_rss)
    return if item_exists?(item_rss)

    feed.items.create do |item|
      # raise item_rss.inspect

      # item.url = 'http://example.com'
      # item.title = 'Item name'
      item.url = item_rss.url
      item.title = item_rss.title
      item.author = item_rss.author
      item.content = item_rss.content
      item.fetched_at = Time.current
      item.published_at = item_rss.published_at
    end
  end

  def item_exists?(item_rss)
    feed.items.where(url: item_rss.url).exists?
  end

  def items
    Fetcher.new(feed).fetch
  end

end
