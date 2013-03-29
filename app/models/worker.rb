# WORKER IS NOT CONCURRENCY SAFE!
# ===============================
class Worker
  def initialize(out = nil, err = nil, options = {})
    @running = true
    @out = out || STDOUT
    @err = err || STDERR
    @verbose = options.fetch(:verbose) { true }
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
    # TODO Use some sort of lock or mutex here for concurrency.
    feed = Feed.refreshable.first
    return if feed.nil?

    out.puts %Q(Refreshing feed #{feed.id} "#{feed.title}")
    refresh(feed)
    out.puts "  Done"
  end

  def wait
    sleep 5
  end

  def verbose?
    @verbose
  end

  def refresh(feed)
    feed.refresh!
  rescue => error
    err.puts error.message
    err.puts error.original_message
    err.puts(*error.original_backtrace) if verbose?

    # TODO
    # Retry the refresh after a delay if the error is a temporary
    # network outage, eg. 500 Errors, Internet not available, etc.
    #   eg. Patron::ConnectionFailed
    #
    # Cancel refresh if the error is parsing related.
    # Maybe mark the feed as unparseable?
    #   eg. RSS::Error
    feed.cancel_refresh
  end
end
