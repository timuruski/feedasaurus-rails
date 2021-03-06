class Feed < ActiveRecord::Base
  # Attributes and validations
  validates :title,
    optional: true
  validates :url,
    presence: false
  validates :site_url,
    optional: true

  # Ugh.
  attr_accessible :site_url, :title, :url


  # FeedRequests are used to make intelligent future requests, handle
  # permanent redirects and track a rough metric on which feeds are
  # unreliable.
  has_many :requests,
    class_name: 'FeedRequest',
    validate: false,
    autosave: false

  def last_request
    requests.first
  end

  def last_successful_request
    requests.successful.first
  end

  # A seed request used to refresh the feed. Once completed it is saved
  # to the database for analysis.
  def build_request
    request_template = last_successful_request
    requests.build do |request|
      request.url = url
      if request_template
        request.etag = request_template.etag
        request.last_modified = request_template.last_modified
      end
    end
  end


  # Associations
  belongs_to :group
  has_many :items, dependent: :destroy


  # Maybe this should be by last_modified?
  default_scope order('last_refreshed_at DESC')

  # Searches for feeds by title.
  scope :search, ->(query) {
    query = "%#{query.downcase}%"
    where('title ILIKE ?', query) }

  scope :enabled, where(:enabled => true)
  scope :disabled, where(:enabled => false)

  # Returns a new Feed based on a URL.
  # If the URL is invalid, the feed's URL will be nil and it will not be
  # a valid feed. If the URL was HTML with an alternate link, then that
  # URL will be used.
  def self.subscribe_to(url)
    FeedSubscriber.new(url).feed
  end

  # Returns a list of feeds to be refreshed.
  scope :refreshable, ->(as_of = Time.current) {
    enabled
      .where('next_refresh_at <= ?', as_of)
      .order('next_refresh_at ASC') }

  # Returns a list of feeds that cannot be refreshed.
  scope :not_refreshable, -> {
    enabled
      .where(:next_refresh_at => nil) }

  # Returns a timestamp for the next refreshable Feed.
  def self.next_refresh_at
    enabled
      .where('next_refresh_at IS NOT NULL')
      .order('next_refresh_at ASC')
      .limit(1)
      .pluck(:next_refresh_at)
      .first
  end

  # TODO Use the Feed#refresh method instead.
  def self.refresh(id)
    feed = find(id)
    feed.refresh
  end

  # Marks all feeds for refreshing.
  def self.refresh_all
    update_all(next_refresh_at: Time.current)
  end

  # Returns the timestamp of the most recently refreshed feed.
  def self.last_refreshed_at
    where('last_refreshed_at IS NOT NULL')
      .order('last_refreshed_at DESC')
      .first.last_refreshed_at
  end

  def self.find_by_url(url)
    where(url: url)
  end

  def mark_as_read(before = nil)
    before ||= Time.current
    items
      .where('created_at < ?', before)
      .update_all(read_at: Time.current)
  end

  # Returns whether a refresh is in progress.
  # This seems wrong.
  def needs_refresh?
    next_refresh_at && last_refreshed_at
  end

  # Returns if a feed is scheduled for refresh.
  def refresh_scheduled?
    next_refresh_at && next_refresh_at <= Time.current
  end

  # Returns whether a refresh is in progress.
  def refresh_in_progress?
    return false if refresh_started_at.nil?
    return true if refresh_started_at && last_refreshed_at.nil?

    refresh_started_at > last_refreshed_at
  end

  # Marks a feed for refreshing.
  def schedule_refresh
    update_attribute(:next_refresh_at, Time.current)
  end

  def cancel_refresh
    update_attribute(:next_refresh_at, nil)
  end

  # Immediately refreshes a feed.
  def refresh!
    current_time = Time.current
    self.refresh_started_at = current_time
    self.next_refresh_at = current_time.advance(seconds: refresh_every)
    save

    if FeedRefresher.refresh(self)
      self.last_refreshed_at = current_time
    end

    self.refresh_started_at = nil
    save
  end

  # Resets a feed so that it has not been updated.
  def reset
    items.destroy_all
    requests.destroy_all
    last_refreshed_at = nil
    next_refresh_at = nil

    save
  end

  # Stops a feed from being automatically refreshed.
  def disable
    self.enabled = false
    self.next_refresh_at = nil
    save
  end

  # Resumes a feed being refreshed.
  def enable
    self.enabled = true
    self.next_refresh_at = Time.current
    save
  end

  # Returns whether a Feed is already in the database or not.
  def exists?
    persisted? ||
      self.class.find_by_url(url).exists?
  end

  def verify_url
    true
  end

end
