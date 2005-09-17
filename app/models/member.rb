class Member < ActiveRecord::Base
  has_many :events
  has_many :participants

end
