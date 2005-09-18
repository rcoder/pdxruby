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

  private

  def status_active
    self.status = EVENT_STATUS[:active]
  end
end
