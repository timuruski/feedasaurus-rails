require 'rss'
require 'ostruct'

class Fetcher
  def initialize(feed)
    @feed = feed
  end

  attr_reader :feed

  def fetch
    begin
      RSS::Parser.parse(xml).items
        .map { |i| convert_item(i) }
    rescue
      []
    end
  end

  def xml
    open(feed.feed_url)
  end

  def convert_item(item)
    new_item = OpenStruct.new

    new_item.url = convert_item_url(item)
    new_item.title = 'Title'
    new_item.author = 'Author'
    new_item.content = 'Lorem ipsum...'
    new_item.published_at = Time.current

    new_item
  end

  def convert_item_url(item)
    case item
    when RSS::Atom::Feed::Link then item.href
    item.link
  end
end
