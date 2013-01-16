class Feed < ActiveRecord::Base
  attr_accessible :favicon, :feed_url, :refreshed_at, :site_url, :title

  default_scope order('refreshed_at DESC')

  belongs_to :group
  has_many :items

  scope :search, lambda { |query| 
    query = "%#{query.downcase}%"
    where('lower(title) LIKE ?', query) }
end
