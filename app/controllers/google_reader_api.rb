require 'nokogiri'

class GoogleReaderAPI < Sinatra::Base
  get '/' do
    content_type :text
    <<-EOS
Google Reader mock API v0.1.0
#{params.to_json}
    EOS
  end

  # authentication?
  before do
    authenticate
  end

  # Raw feed as ATOM format
  get '/atom/feed/:feed_url' do
    count = params[:n]
    order = params[:r]
    start_time = params[:ot]
    timestamp = params[:ck]
    exclude_target = params[:xt]
    continuation = params[:c]

    # Find feed, convert to Atom and return it
  end

  # User-specified labels
  get '/atom/user/:user_id/label/:label'

  # Google-specified states:
  #   read, kept-unread, fresh, starred, broadcast, reading-list,
  #   tracking-body-link-used, tracking-emailed, tracking-item-link-used, tracking-kept-unread
  get '/atom/user/:user_id/state/com.google/:state'


  get '/api/0/token' do
    timestamp = params[:ck] # ??
  end

  get '/api/0/subscription/edit' do
    feed = params[:s] # feed/<feed-name>
    title = params[:t]
    add = params[:a]
    remove = params[:r]
    action = params[:ac]
    token = params[:token]
  end

  get '/api/0/tag/edit' do
    feed = params[:s]
    public = params[:pub] # boolean
  end

  get '/api/0/edit-tag' do
    entry = params[:i]
    add = params[:a]
    remove = params[:r]
    action = params[:ac]
  end

  get '/api/0/disable-tag' do
    feed = params[:s]
    action = params[:ac]
  end


  def authenticate
  end
end
