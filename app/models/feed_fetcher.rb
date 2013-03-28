require 'patron'

class FeedFetcher

  def initialize(request)
    @request = request
  end

  attr_reader :request

  # Returns a RawFeed based on the fetch operation.
  # If there is new content, a new RawFeed instance is returned with the
  # updates. If there is no change, the original RawFeed is returned.
  def fetch
    response = get_request
    # Need some way to record 404s and such so that they can be filtered
    # out or updated when a feed moves, etc.
    # Also need to handle permanent redirects, etc.
    if response.success?
      FeedRequest.new do |request|
        request.parse_response(response)
      end
    else
      request
    end
  end


  # Convenience
  def self.fetch(request)
    new(request).fetch
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
    response = session.get(url.path, request_headers)
    response.extend StatusQuery
    response
  end

  def url
    @url ||= URI.parse(request.url)
  end

  def request_headers
    etag = request.etag
    last_modified = request.last_modified.try(:httpdate)

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
