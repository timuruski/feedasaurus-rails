require 'nokogiri'

class FeedImporter < Struct.new(:file)
  def self.import(file, &block)
    new(file).import(&block)
  end

  def import(&block)
    feeds.each do |feed|
      next if Feed.where(url: feed.url).exists?

      yield feed if block_given?
      feed.save!
    end
  end

  protected

  def feeds
    feed_elements.map { |e| Feed.new(e) }
  end

  def feed_elements
    xml.xpath("//outline[@type='rss']")
      .map { |e|
        { url: e['xmlUrl'],
          site_url: e['htmlUrl'],
          title: e['title'] }
      }
  end

  def xml
    Nokogiri.parse(file.read)
  end

end
