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
    case item
    when RSS::Rss::Channel::Item then convert_rss(item)
    when RSS::Atom::Feed::Entry then convert_atom(item)
    when RSS::RDF::Item then convert_rdf(item)
    end
  end

  def convert_rss(item)
    new_item = OpenStruct.new

    new_item.url = convert_link(item.link)
    new_item.title = item.title
    # new_item.author = item.author
    # new_item.content = item.content
    new_item.published_at = Time.current

    new_item
  end

  def convert_atom(item)
    new_item = OpenStruct.new

    new_item.url = convert_link(item.link)
    new_item.title = item.title
    new_item.author = item.author
    new_item.content = item.content
    new_item.published_at = item.published

    new_item
  end

  def convert_rdf(item)
    new_item = OpenStruct.new

    new_item.url = convert_link(item.link)
    new_item.title = item.title
    # new_item.author = item.author
    # new_item.content = item.content
    new_item.published_at = Time.current

    new_item
  end

  def convert_link(link)
    item.respond_to?(:href) ? item.href : item.to_s
  end
end
