class Participant < ActiveRecord::Base
  PARTICIPANT_ATTENDING = { :yes      =>      'yes',
                            :no       =>      'no',
		            :maybe    =>      'maybe'}

  belongs_to :event
  belongs_to :member
  has_many :feedbacks

  validates_presence_of :member_id
  validates_presence_of :event_id
  validates_presence_of :attending

  # make sure the attending is in PARTICIPANT_ATTENDING
  validates_each :attending do |rec,attr|
    rec.errors.add attr, 'that response is not one I know about' unless PARTICIPANT_ATTENDING.has_value? rec.send(attr)
  end

  def is_attending?
     %w( yes maybe ).member?(self.attending)
  end

  def self.find_upcoming(member_id)
    return self.find_by_sql("SELECT * FROM events e, participants p " +
      "WHERE p.event_id=e.id AND p.member_id=#{member_id} AND e.starts_at>now()")
  end
end
