class FeedSubscriber
  def initialize(url)
    @url = url
  end

  attr_reader :url

  # Fetch URL
  # Return a Feed if the URL is for a feed
  # Return a Feed if the URL is HTML but has an unambiguous link-alt
  # tag.
  # Return an invalid Feed if the URL isn't valid
  def feed
    Feed.new(url: url)
  end

  # Returns a Feed derived from the URL provided.
  def self.build_feed(url)
    new(url).feed
  end

end
