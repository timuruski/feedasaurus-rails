class Feed < ActiveRecord::Base
  attr_accessible :favicon, :feed_url, :refreshed_at, :site_url, :title

  belongs_to :group
  has_many :items
end
