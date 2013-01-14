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
      create_entry(item_rss)
    end

    feed.update_attribute(:refreshed_at, Time.current)
    feed
  end

  def create_entry(item_rss)
    feed.items.create do |item|
      # raise item_rss.inspect

      # item.url = 'http://example.com'
      # item.title = 'Item name'
      item.url = item_rss.link
      item.title = item_rss.title
      item.author = item_rss.author
      itemcontentbody = item_rss.description
      item.fetched_at = Time.current
      item.published_at = item_rss.pubDate
    end
  end

  def items
    begin
      xml = open(feed.feed_url)
      rss = RSS::Parser.parse(xml)
      rss.items
    rescue
      []
    end
  end

end
