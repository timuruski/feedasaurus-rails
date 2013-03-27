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
    store_raw_xml(request)


    # Update items
    items = parse_items(request)
    items.each do |item_rss|
      create_item(item_rss)
    end

    # Update the request

    # Store 

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
  end

  def store_raw_xml(request)
    FileUtils.mkdir_p(raw_feed.storage_dir)
    File.open(raw_feed.storage_path, 'w') do |f|
      f << String(raw_feed.xml)
    end
  end

  def stored?
    File.exists?(storage_path)
  end

  def storage_path
    digest = Digest::MD5.hexdigest(url)
    Rails.root.join('public', 'raw_feeds', "#{digest}.xml")
  end

  def storage_dir
    storage_path.dirname
  end

  # def remove_raw_xml
  #   File.delete(raw_feed.storage_path) if raw_feed.stored?
  # end



end
