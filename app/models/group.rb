class Group < ActiveRecord::Base
  attr_accessible :name
  has_many :feeds, dependent: :nullify
end
