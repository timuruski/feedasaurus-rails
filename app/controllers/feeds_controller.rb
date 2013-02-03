class FeedsController < ApplicationController
  def index
    @feeds = Feed.all
  end

  def show
    @feed = Feed.find(params[:id])
  end

  def refresh
    @feed = Feed.find(params[:id])
    @feed.schedule_refresh

    redirect_to @feed
  end

  def new
    @feed = Feed.new
  end

  def create
    @feed = Feed.new
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
