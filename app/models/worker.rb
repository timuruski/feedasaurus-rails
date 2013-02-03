class Worker
  def initialize
    @running = true
  end

  def start
    while @running
      work
      wait
    end
  end

  def stop
    @running = false
  end

  def work
    feed = Feed.refreshable.first
    return if feed.nil?

    feed.refresh!
  end

  def wait
    sleep 15
  end
end
