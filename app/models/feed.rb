class Feed < ActiveRecord::Base
  # Attributes and validations
  validates :title,
    optional: true
  validates :url,
    presence: false
  validates :site_url,
    optional: true
  validates :favicon,
    optional: true
  # validates :username
  # validates :password

  # Associations
  belongs_to :group
  has_one :raw_feed, dependent: :destroy
  has_many :items, dependent: :destroy

  default_scope order('last_refreshed_at DESC')

  # Searches for feeds by title.
  scope :search, lambda { |query|
    query = "%#{query.downcase}%"
    where('title ILIKE ?', query) }

  scope :enabled, where(:enabled => true)
  scope :disabled, where(:enabled => false)

  # Returns a list of feeds to be refreshed.
  scope :refreshable, lambda {
    where('next_refresh_at <= ?', Time.current)
      .enabled
      .order('next_refresh_at ASC') }

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
  def refresh_in_progess?
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
    update_attribute(:refresh_started_at, Time.current)

    if FeedRefresher.refresh(self)
      current_time = Time.current
      self.last_refreshed_at = current_time
      self.next_refresh_at = current_time.advance(seconds: refresh_every)
    end

    self.refresh_started_at = nil
    save
  end

  # Resets a feed so that it has not been updated.
  def reset
    items.destroy_all
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
end
