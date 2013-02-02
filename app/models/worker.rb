class Worker
  def initialize
    @running = true
  end

  def start
    while @running
      feed_count = Feed.count
      puts "Found #{feed_count} #{'feed'.pluralize(feed_count)}"
      sleep 15
    end
  end

  def stop
    @running = false
  end
end
