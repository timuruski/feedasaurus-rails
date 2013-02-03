module FeedsHelper
  def feed_refresh_text(feed)
    return 'Never refreshed' unless feed.last_refreshed_at?

    "Refreshed #{time_ago_in_words(feed.last_refreshed_at)} ago"
  end
end
