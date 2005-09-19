class Event < ActiveRecord::Base
  before_create :status_active

  EVENT_STATUS = { :active 	=>	'active',
                   :canceled 	=>	'cancelled' }

  belongs_to :member
  belongs_to :location
  has_many :participants

  validates_presence_of :name
  validates_presence_of :agenda
  validates_presence_of :starts_at
  validates_presence_of :ends_at
  validates_presence_of :location_id
  
  def cancelled?
    self.status == EVENT_STATUS[:canceled]
  end
  
  def cancel!
    self.status = EVENT_STATUS[:canceled]
  end
  
  def active?
    self.status == EVENT_STATUS[:active]
  end
  
  def active!
    self.status = EVENT_STATUS[:active]
  end
  
  def has_participant(member)
    self.participants.map {|p| p.member}.member?(member)
  end
  
  def started?
    self.starts_at < Time.now
  end
  
  def ended?
    self.ends_at < Time.now
  end

  private

  def status_active
    self.status = EVENT_STATUS[:active]
  end
end
