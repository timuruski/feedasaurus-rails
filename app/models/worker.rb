class Worker
  def initialize(out = nil)
    @running = true
    @out = out || STDOUT
  end

  attr_reader :out

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
    feed.refresh!
    out.puts "  Done"
  end

  def wait
    sleep 15
  end
end
