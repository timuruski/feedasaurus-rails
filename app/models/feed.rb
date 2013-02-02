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
  has_many :items

  default_scope order('refreshed_at DESC')
  scope :search, lambda { |query|
    query = "%#{query.downcase}%"
    where('lower(title) LIKE ?', query) }

  # TODO Use the Feed#refresh method instead.
  def self.refresh(id)
    feed = find(id)
    FeedRefresher.refresh(feed)
  end

  # Returns whether a refresh is in progress.
  def refreshing?
    return false if refresh_started_at.nil?
    return true if refreshed_at.nil?

    refresh_started_at > refreshed_at
  end

  # NOTE Not in use yet.
  def refresh
    update_attribute(:refresh_started_at, Time.current)
    FeedRefresher.refresh(self)
    feed.update_attribute(:refreshed_at, Time.current)
  end

  # Resets a feed so that it has not been updated.
  def reset
    items.destroy_all
    update_attributes(refreshed_at: nil)
  end
end
