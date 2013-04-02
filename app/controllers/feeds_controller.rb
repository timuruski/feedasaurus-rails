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

  def new
    @feed = Feed.new
  end

  def create
    @feed = Feed.new(params)
    # Validate feed is XML
    # Validate feed isn't a duplicate
    # Handle multiple alternates
    redirect_to action: :index
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
