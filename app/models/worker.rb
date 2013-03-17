class Worker
  def initialize(out = nil, err = nil)
    @running = true
    @out = out || STDOUT
    @err = err || STDERR
  end

  attr_reader :out, :err

  def start
    out.puts "Worker started"
    while @running
      work
      wait
    end
  end

  def stop
    out.puts "Worker stopped"
    @running = false
  end

  def work
    feed = Feed.refreshable.first
    return if feed.nil?

    out.puts %Q(Refreshing feed #{feed.id} "#{feed.title}")
    refresh(feed)
    out.puts "  Done"
  end

  def wait
    sleep 15
  end

  def refresh(feed)
    feed.refresh!
  rescue => error
    err.puts "  An error occurred, #{error.inspect}"
    # Should mark the feed as errored on some way.
    # Also dumping a stack trace out would be helpful.
    feed.cancel_refresh
  end
end
