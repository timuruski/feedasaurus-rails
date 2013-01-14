# require 'config/environment'

namespace :feeds do
  desc "Refresh the items in a feed"
  task :refresh, :feed_id do |t, args|
    feed = Feed.find(args[:feed_id])
    puts feed.title
  end
end
