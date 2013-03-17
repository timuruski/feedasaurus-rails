class Item < ActiveRecord::Base
  attr_accessible :author, :body, :fetched_at, :read_at, :starred_at, :title, :url
  belongs_to :feed

  scope :read, -> { where('read_at IS NOT NULL') }
  scope :unread, -> { where('read_at IS NULL') }
  scope :starred, -> { where('starred_at IS NOT NULL') }
  scope :unstarred, -> { where('starred_at IS NULL') }

  # Returns whether an item has been read.
  def read?
    not read_at.nil?
  end

  # Returns whether an item has been starred.
  def starred?
    not starred_at.nil?
  end
end
