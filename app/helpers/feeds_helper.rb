module FeedsHelper
  def feed_refresh_text(feed)
    return 'Never refreshed' unless feed.refreshed_at?

    "Refreshed #{time_ago_in_words(feed.refreshed_at)} ago"
  end
end
