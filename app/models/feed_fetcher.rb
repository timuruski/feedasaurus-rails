require 'patron'

class FeedFetcher < Struct.new(:raw_feed)
  def self.fetch(raw_feed)
    new(raw_feed).fetch
  end

  def self.fetch_head(raw_feed)
    new(raw_feed).fetch_head
  end

  def fetch
    response = get_request
    raw_feed.response = response if (200..299).cover?(response.status)
    raw_feed
  end

  def fetch_get
    session.get(url.path)
  end

  def fetch_head
    session.head(url.path)
  end

  protected

  def get_request
    session.get(url.path, request_headers)
  end

  def url
    @url ||= URI.parse(raw_feed.url)
  end

  def request_headers
    { 'If-None-Match' => raw_feed.etag,
      'If-Modified-Since' => raw_feed.last_modified }
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
