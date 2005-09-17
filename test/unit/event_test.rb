require File.dirname(__FILE__) + '/../test_helper'

class EventTest < Test::Unit::TestCase
  fixtures :events

  def setup
    @event = Event.find(1)
  end

  # Replace this with your real tests.
  def test_truth
    assert_kind_of Event,  @event
  end
end
