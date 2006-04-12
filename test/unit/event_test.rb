require File.dirname(__FILE__) + '/../test_helper'

class EventTest < Test::Unit::TestCase
  fixtures :events, :feedbacks, :locations, :members, :participants

  def setup
    @event = Event.new

    @event.name = 'Unit test'
    @event.agenda = 'Testing stuff'
    @event.starts_at = Time.now
    @event.ends_at = Time.now
    @event.location = locations(:first)
    @event.status = 'active'
  end

  def test_create_read_update_delete
    assert(@event.save)

    read_event = locations(:first).events.find_by_name('Unit test')

    assert_equal(@event.agenda, read_event.agenda)

    @event.agenda = 'Testing a lot of stuff'

    assert(@event.save)

    assert(@event.destroy)
  end

  def test_associations
    assert_kind_of(Member, events(:peats_baby_shower).member)
    assert_kind_of(Location, events(:peats_baby_shower).location)
    assert_kind_of(Array, events(:peats_baby_shower).participants)
  end

  def test_validates_presence_of_name
    @event.name = nil

    assert_equal(false, @event.save)
  end

  def test_validates_presence_of_agenda
    @event.agenda = nil

    assert_equal(false, @event.save)
  end

  def test_validates_presence_of_starts_at
    @event.starts_at = nil

    assert_equal(false, @event.save)
  end

  def test_validates_presence_of_ends_at
    @event.ends_at = nil

    assert_equal(false, @event.save)
  end

  def test_validates_presence_of_location_id
    @event.location = nil

    assert_equal(false, @event.save)
  end

  def test_validates_length_of_name
    @event.name = 'This is a very long name for an event - perhaps even ' +
      'a little bit *too* long.  Oh no!'

    assert_equal(false, @event.save)
  end

  def test_validates_status
    @event.status = nil

    assert_equal(false, @event.save)
  end

  def test_validates_starts_at
    @event.starts_at = Time.now + 1000

    assert_equal(false, @event.save)
  end

  def test_validates_ends_at
    @event.ends_at = Time.now - 1000

    assert_equal(false, @event.save)
  end

  def test_cancelled?
    assert_equal(false, @event.cancelled?)
  end

  def test_cancel!
    @event.cancel!

    assert(@event.cancelled?)
  end

  def test_active?
    assert_equal(true, @event.active?)
  end

  def test_active!
    @event.cancel!

    assert_equal(false, @event.active?)

    @event.active!

    assert(@event.active?)
  end

  def test_has_participant
    assert_equal(false,
                 events(:peats_baby_shower).has_participant(members(:sue)))

    assert_equal(true,
                 events(:peats_baby_shower).has_participant(members(:bob)))
  end

  def test_started?
    @event.starts_at = Time.now - 1000
    @event.ends_at = Time.now + 1000

    assert_equal(true, @event.started?)
  end

  def test_ended?
    @event.starts_at = Time.now - 2000
    @event.ends_at = Time.now - 1000

    assert_equal(true, @event.ended?)
  end

  def test_feedbacks
    assert_equal([ feedbacks(:first) ], events(:peats_baby_shower).feedbacks)
  end

  def test_unclaimed?
    assert_equal(true, @event.unclaimed?)
  end

  def test_find_upcoming
    assert_equal([ events(:bens_high_school_prom) ], Event.find_upcoming)
  end

  def test_find_recent
    assert_equal([ events(:peats_baby_shower) ], Event.find_recent)
  end
end
