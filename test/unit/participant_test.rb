require File.dirname(__FILE__) + '/../test_helper'

class ParticipantTest < Test::Unit::TestCase
  fixtures :participants

  def setup
    @participant = Participant.find(1)
  end

  # Replace this with your real tests.
  def test_truth
    assert_kind_of Participant,  @participant
  end
end
