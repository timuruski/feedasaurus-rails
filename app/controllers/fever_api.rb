class FeverAPI < Sinatra::Base

  # This mocks the parts of the Fever API used by Reeder 3.0 6 for iOS
  VERSION = 3.freeze

  # Extracts the 'action' portion of a request.
  # The Fever API docs say these needs to be part of the URL and it will
  # ignore these if they are POSTed, but it seems like a waste of time
  # to emulate this behaviour.
  set(:action) do |*actions|
    condition do
      return true if actions.first == :none
      actions.any? { |a| params.has_key?(a.to_s) }
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


  # Groups
  api_call :groups do
    groups = Group.all.map { |g|
      { id: g.id, title: g.name } }
    json_response groups: groups,
                  feeds_groups: feeds_groups
  end

  # Feeds
  api_call :feeds do
    feeds = []
    json_response feeds: feeds,
                  feeds_groups: feeds_groups
  end

  # Favicons
  api_call :favicons do
    favicons = []
    json_response favicons: favicons
  end

  # Items
  api_call :items do
    items = []
    total_items = 0

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
    unread_item_ids = ''
    json_response unread_item_ids: unread_item_ids
  end

  # Sync saved items
  api_call :saved_item_ids do
    saved_item_ids = ''
    json_response saved_item_ids: saved_item_ids
  end

  # Authenticate/handshake
  api_call :none do
    json_response
  end


  protected


  def feeds_groups
    Group.all.map { |g|
      feed_ids = Feed.where(:group_id => g.id).pluck(:id).join(',')
      { group_id: g.id, feed_ids: feed_ids } }
  end

  # 
  def api_action?
    params.has_key?('api')
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
