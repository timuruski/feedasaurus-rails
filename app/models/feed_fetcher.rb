require 'rss'
require 'patron'

class FeedFetcher < Struct.new(:feed)
  def self.fetch(feed)
    new(feed).fetch
  end

  def fetch
    begin
      RSS::Parser.parse(xml)
    rescue => e
      raise e
    end
  end

  protected

  def xml
    begin
      # Need to store some of the response information to be a good
      # network citizen.
      response = session.get(url.path)
      response.body
    rescue => e
      puts e
    end
  end

  def url
    @url ||= URI.parse(feed.url)
  end

  def session
    @session ||= build_session
  end

  def build_session
    session = Patron::Session.new
    session.base_url = "#{url.scheme}://#{url.hostname}"
    session
  end

end
