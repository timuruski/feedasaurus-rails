require 'base64'

class FeverAPI < Sinatra::Base

  # This mocks the parts of the Fever API used by Reeder 3.0 6 for iOS
  VERSION = 3.freeze
  DEFAULT_FAVICON = Base64.encode64(File.open('public/rss-icon.png', 'rb').read).gsub(/\n/,'')

  # Extracts the 'action' portion of a request.
  # The Fever API docs say these needs to be part of the URL and it will
  # ignore these if they are POSTed, but it seems like a waste of time
  # to emulate this behaviour.
  set(:action) do |action|
    condition do
      return true if action == :none
      params.has_key?(action.to_s)
    end
  end

  configure do
    mime_type :json, 'text/json'
    enable :logging
  end

  # Handle some minor authentication.
  before do
    if request.post? && api_action?
      logger.info params.to_json
      halt unauthorized unless params[:api_key] == ENV['FEVER_API_KEY']
    end
    # Handle XML data type ?api=xml
  end

  # Sugar for building routes
  def self.api_call(name, &block)
    post('/', action: name, &block)
  end


  # Refresh feeds.
  get '/' do
    pass unless refresh?
    Feed.refresh_all

    nil
  end

  # Groups
  api_call :groups do
    groups = Group.all.map { |g|
      { id: g.id, title: g.name } }
    json_response groups: groups,
                  feeds_groups: feeds_groups
  end

  # Feeds
  api_call :feeds do
    feeds = Feed.all.map { |f|
      { id: f.id, title: f.title,
        url: f.url, site_url: f.site_url,
        last_updated_on_time: f.last_refreshed_at.to_i,
        is_spark: 0, favicon_id: 0 }
    }

    json_response feeds: feeds,
                  feeds_groups: feeds_groups
  end

  # Favicons
  api_call :favicons do
    default_icon = { id: 0, data: "image/png;base64,#{DEFAULT_FAVICON}" }
    favicons = [ default_icon ]

    json_response favicons: favicons
  end

  # Items
  api_call :items do
    items_query = build_items_query(params)
    items = items_query.to_a.map { |i|
      { id: i.id, feed_id: i.feed_id,
        title: i.title, author: i.author, html: i.content,
        url: i.url, created_on_time: i.created_at.to_i,
        is_read: i.read?, is_saved: i.starred? }
    }
    total_items = Item.count

    json_response items: items,
                  total_items: total_items
  end

  # Hot Links
  api_call :links do
    links = []
    json_response links: links
  end

  # Sync unread items
  api_call :unread_item_ids do
    unread_item_ids = Item.unread.pluck(:id).join(',')
    json_response unread_item_ids: unread_item_ids
  end

  # Sync saved items
  api_call :saved_item_ids do
    saved_item_ids = Item.starred.pluck(:id).join(',')
    json_response saved_item_ids: saved_item_ids
  end

  # Write item read
  api_call :mark do
    case params[:mark]
    when 'item' then mark_item(params)
    when 'feed' then mark_feed_as_read(params)
    # I don't think Reeder marks groups as read.
    end
  end


  # Authenticate/handshake
  api_call :none do
    json_response
  end


  protected


  def feeds_groups
    Group.all.map { |g|
      feed_ids = g.feeds.pluck(:id).join(',')
      { group_id: g.id, feed_ids: feed_ids }
    }
  end

  # Builds an items query from request params.
  def build_items_query(params)
    min_id = params[:since_id]
    max_id = params[:max_id]
    item_ids = String(params[:with_ids]).split(',')

    query = Item.order('id ASC')
    query = query.where("id <= ?", max_id).limit(50) if max_id
    query = query.where("id > ?", min_id).limit(50) if min_id
    query = query.where(:id => item_ids) if item_ids.any?

    query
  end

  def mark_item(params)
    item_id = params.fetch('id')
    item = Item.find(item_id)
    mark = params.fetch('as')

    case mark
    when 'read' then item.mark_as_read
    when 'unread' then item.mark_as_unread
    when 'saved' then item.mark_as_starred
    when 'unsaved' then item.mark_as_unstarred
    end
  end

  def mark_feed_as_read(params)
    feed_id = params.fetch('id')
    feed = Feed.find(feed_id)

    before_time = Time.zone.at(params[:before])
    feed.mark_as_read(before_time)
  end

  # 
  def api_action?
    params.has_key?('api')
  end

  def refresh?
    params.has_key?('refresh')
  end

  # Constructs a JSON response.
  def json_response(data = {})
    base = {
      'api_version' => VERSION,
      'auth' => 1,
      'last_refreshed_on_time' => Feed.last_refreshed_at.to_i
    }

    content_type :json
    base.merge(data).to_json
  end

  def unauthorized
    return [ 200, { 'Content-Type' => 'text/json' }, <<-EOS ]
{
    "api_version": #{VERSION},
    "auth": 0,
}
    EOS
  end
end
