class Feed < ActiveRecord::Base
  validates :title,
    presence: true

  attr_accessible :favicon, :feed_url, :refreshed_at, :site_url, :title

  belongs_to :group
  has_many :items

  default_scope order('refreshed_at DESC')
  scope :search, lambda { |query|
    query = "%#{query.downcase}%"
    where('lower(title) LIKE ?', query) }

  #
  # Resets a feed so that it has not been updated.
  def reset!
    items.destroy_all
    update_attributes(refreshed_at: nil)
  end
end
