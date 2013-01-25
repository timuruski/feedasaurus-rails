require 'rss'

class Refresher < Struct.new(:feed)
  def self.refresh!(feed)
    new(feed).refresh!
  end

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
    item = ItemConverter.convert(item_rss)
    return if item_exists?(item)

    item.feed = feed
    item.fetched_at = Time.current
    item.save
  end

  def item_exists?(item_rss)
    feed.items.where(url: item_rss.url).exists?
  end

  def items
    @items ||= Fetcher.new(feed).fetch.items
  end

end
