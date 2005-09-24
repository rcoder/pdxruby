class Member < ActiveRecord::Base
  has_many :events
  has_many :participants
  
  validates_presence_of :name
  validates_presence_of :email
  validates_presence_of :password

  validates_uniqueness_of :email

end
