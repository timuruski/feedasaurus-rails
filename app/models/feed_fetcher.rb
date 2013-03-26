require 'patron'

class FeedFetcher

  def initialize(raw_feed)
    @raw_feed = raw_feed
  end

  attr_reader :raw_feed

  # Returns a RawFeed based on the fetch operation.
  # If there is new content, a new RawFeed instance is returned with the
  # updates. If there is no change, the original RawFeed is returned.
  def fetch
    response = get_request
    # Need some way to record 404s and such so that they can be filtered
    # out or updated when a feed moves, etc.
    # Also need to handle permanent redirects, etc.
    raw_feed.response = response if response.success?
    raw_feed
  end


  # Convenience
  def self.fetch(raw_feed)
    new(raw_feed).fetch
  end


  # Debugging
  def fetch_get
    session.get(url.path)
  end

  # Debugging
  def fetch_head
    session.head(url.path)
  end

  protected

  def get_request
    response.session.get(url.path, request_headers)
    response.extend StatusQuery
    response
  end

  def url
    @url ||= URI.parse(raw_feed.url)
  end

  def request_headers
    etag = raw_feed.etag
    last_modified = raw_feed.last_modified.try(:httpdate)

    headers = {}
    headers['If-None-Match'] = etag if etag.present?
    headers['If-Modified-Since'] = last_modified if last_modified.present?

    headers
  end

  def session
    @session ||= build_session
  end

  def build_session
    session = Patron::Session.new
    session.base_url = "#{url.scheme}://#{url.hostname}"
    session.connect_timeout = 3
    session.timeout = 10
    session
  end

  module StatusQuery
    def success?
      (200..299).cover?(status)
    end

    def redirect?
      (300..399).cover?(status)
    end

    def not_found?
      status == 404
    end

    def moved_permanently?
      status == 301
    end
  end

end
