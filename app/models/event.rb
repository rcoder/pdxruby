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

  validates_length_of :name, :maximum => 64

  # make sure the status is in EVENT_STATUS
  validates_each :status do |rec,attr|
    rec.errors.add attr, 'that status is not one I know about' unless EVENT_STATUS.has_value? rec.send(attr)
  end

  # make sure the start time is in the future (unless it is already past)
  validates_each :starts_at do |rec, attr|
    unless rec.ends_at.nil? || rec.ends_at < Time.now
      rec.errors.add attr, 'must be later than now' if rec.starts_at && rec.starts_at < Time.now
    end
  end

  # make sure the end time is later than the start time (i.e. interval is positive)
  validates_each :ends_at do |rec, attr|
    rec.errors.add attr, 'must be later than start time' if rec.starts_at && rec.ends_at && rec.ends_at < rec.starts_at
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

  def unclaimed?
    nil == self.member
  end

  def Event.find_upcoming(limit=10)
    find(:all, :limit => limit, :order => 'starts_at desc',
         :conditions => ['starts_at > ? and status = ?', Time.now, EVENT_STATUS[:active]])
  end

  def Event.find_recent(limit=10)
    find(:all, :limit => limit, :order => 'ends_at desc')
    find(:all, :limit => limit, :order => 'ends_at desc',
         :conditions => ['ends_at < ? and status != ?', Time.now, EVENT_STATUS[:canceled]])
  end

  def Event.find_within_range(start, finish)
    find(
      :all, :order => 'ends_at desc',
      :conditions => ['ends_at >= ? and ends_at <= ? and status != ?', start, finish, EVENT_STATUS[:canceled]]
    )
  end

  private

  def status_active
    self.status = EVENT_STATUS[:active]
  end
end

# vi:ts=2:sw=2:et
