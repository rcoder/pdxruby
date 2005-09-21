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
  
  validates_each :starts_at, :ends_at do |rec, attr|
  	rec.errors.add attr, 'must be later than now' if rec.send(attr) < Time.now
  end
  
  validates_each :ends_at do |rec, attr|
  	rec.errors.add attr, 'must be later than start time' if rec.ends_at < rec.starts_at
  end
  
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
    self.participants.map {|p| p.member }.member?(member)
  end
  
  def started?
    self.starts_at < Time.now
  end
  
  def ended?
    self.ends_at < Time.now
  end
  
  def feedbacks
  	self.participants.map {|p| p.feedbacks }.flatten
  end
  
  def Event.find_upcoming(limit=10)
    find(:all, :limit => limit, :order_by => 'starts_at desc', 
         :conditions => ['starts_at > ? and status = ?', Time.now, EVENT_STATUS[:active]])
  end
  
  def Event.find_recent(limit=10)
    find(:all, :limit => limit, :order_by => 'ends_at desc',
         :conditions => ['ends_at < ? and status = ?', Time.now, EVENT_STATUS[:upcoming]])
  end

  private

  def status_active
    self.status = EVENT_STATUS[:active]
  end
end
