class Item < ActiveRecord::Base
  attr_accessible :author, :body, :fetched_at, :read_at, :starred_at, :title, :url
  belongs_to :feed
end
