require 'patron'
require 'rss'

class FeedSubscriber
  def initialize(url)
    @url = URI.parse(url)
  end

  attr_reader :url

  # Fetch URL
  # Return a Feed if the URL is for a feed
  # Return a Feed if the URL is HTML but has an unambiguous link-alt
  # tag.
  # Return an invalid Feed if the URL isn't valid
  def feed
    valid_url = validate_url
    valid_url ? Feed.new(url: valid_url) : NoFeed.new(url: url)
  end


  protected


  def validate_url
    response = get_url
    return unless response.status == 200

    # Try to parse RSS from the content.
    document = RSS::Parser.parse(response.body) rescue nil
    return response.url if document

    # Try to extract an alternate-link from a regular webpage.
    document = Webpage.new(response)
    document.alternate_url
  end

  def get_url
    session = Patron::Session.new
    session.get(url)
  end
end
