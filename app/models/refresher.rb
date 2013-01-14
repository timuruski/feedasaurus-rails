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
      item.url = item_rss.source
      item.title = item_rss.title.to_s
      # item.author = item_rss.author
      # item.body = item_rss.content
      item.fetched_at = Time.current
      # item.published_at = Time.parse(item_rss.pub_date)
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
