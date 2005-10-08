class Member < ActiveRecord::Base
  has_many :events
  has_many :participants
  
  validates_presence_of :name
  validates_presence_of :email
  validates_presence_of :password

  validates_uniqueness_of :email

  validates_length_of :name, :maximum => 128
  validates_length_of :email, :maximum => 128
  validates_length_of :feed_url, :maximum => 256

end
