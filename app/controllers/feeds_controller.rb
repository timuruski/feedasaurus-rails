class FeedsController < ApplicationController
  def index
    @feeds = Feed.all
    @new_feed = Feed.new
  end

  def show
    @feed = Feed.find(params[:id])
  end

  def refresh
    @feed = Feed.find(params[:id])
    @feed.schedule_refresh

    redirect_to :back
  end

  def subscribe
    feed = Feed.subscribe_to(params[:feed_url])

    if feed.invalid?
      flash[:alert] = "This URL is not a valid feed."
    elsif feed.exists?
      flash[:alert] = "You are already subscribed to this feed."
    else
      flash[:notice] = feed.url
    end

    # Need to get the feed name.

    redirect_to action: :index
  end

  # Scaffoldingy kind of stuff.

  def new
    @feed = Feed.new
  end

  def create
    @feed = Feed.new(params[:feed])
  end

  def edit
    @feed = Feed.find(params[:id])
  end

  def update
    @feed = Feed.find(params[:id])
  end

  def destroy
    @feed = Feed.find(params[:id])
  end
end
