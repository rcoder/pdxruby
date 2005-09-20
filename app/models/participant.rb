class Participant < ActiveRecord::Base
  belongs_to :event
  belongs_to :member
  has_many :feedbacks

  validates_presence_of :member_id
  validates_presence_of :event_id
  validates_presence_of :attending
end
