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
        .map { |i| ItemConverter.new(i).convert }
    rescue
      []
    end
  end

  def xml
    open(feed.feed_url)
  end

end
