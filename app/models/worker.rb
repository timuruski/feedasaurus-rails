class Worker
  def initialize(out = nil)
    @running = true
    @out = out || STDOUT
  end

  attr_reader :out

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

    out.puts %Q(Refreshing feed #{feed.id} "#{feed.title}")
    feed.refresh!
    out.puts "  Finished"
  end

  def wait
    sleep 15
  end
end
