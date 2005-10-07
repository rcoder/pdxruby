class Participant < ActiveRecord::Base
  belongs_to :event
  belongs_to :member
  has_many :feedbacks

  validates_presence_of :member_id
  validates_presence_of :event_id
  validates_presence_of :attending

  def self.find_upcoming(member_id)
    return self.find_by_sql "SELECT * FROM events e, participants p " +
      "WHERE p.event_id=e.id AND p.member_id=#{member_id} AND e.starts_at>now()"
  end
end
