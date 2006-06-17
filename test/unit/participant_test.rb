require File.dirname(__FILE__) + '/../test_helper'

class ParticipantTest < Test::Unit::TestCase
  fixtures :events, :members, :participants

  def setup
    @participant = Participant.new

    @participant.event = events(:prom)
    @participant.member = members(:bob)
    @participant.attending = 'maybe'
  end

  def test_create_read_update_delete
    assert(@participant.save)

    read_participant = Participant.find @participant.id

    assert_equal(@participant.id, read_participant.id)

    @participant.attending = 'yes'

    assert(@participant.save)

    assert(@participant.destroy)
  end

  def test_associations
    assert_kind_of(Event, participants(:first).event)
    assert_kind_of(Member, participants(:first).member)
    assert_kind_of(Array, participants(:first).feedbacks)
  end

  def test_validates_presence_of_member
    @participant.member = nil

    assert_equal(false, @participant.save)
  end

  def test_validates_presence_of_event
    @participant.event = nil

    assert_equal(false, @participant.save)
  end

  def test_validates_attending
    @participant.attending = 'dunno'

    assert_equal(false, @participant.save)
  end

  def test_is_attending?
    assert(@participant.is_attending?)
  end

  def test_find_upcoming
    assert_equal([ participants(:first) ],
                 Participant.find_upcoming(members(:bob).id))
  end
end
