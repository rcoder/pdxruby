class Location < ActiveRecord::Base
  has_many :events

  validates_presence_of :name
  validates_presence_of :address

  validates_uniqueness_of :name
  validates_uniqueness_of :address

  validates_length_of :name, :maximum => 64
  validates_length_of :homepage, :maximum => 256
  
end
