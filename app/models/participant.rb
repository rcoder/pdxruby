class Participant < ActiveRecord::Base
  belongs_to :event
  belongs_to :member
  has_many :feedbacks

end
