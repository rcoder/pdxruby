require File.dirname(__FILE__) + '/../test_helper'

class FeedbackTest < Test::Unit::TestCase
  fixtures :feedbacks

  def setup
    @feedback = Feedback.new
  end

  def test_create_read_update_delete
    assert(@feedback.save)

    read_feedback = Feedback.find @feedback.id

    assert_equal(@feedback.id, read_feedback.id)

    @feedback.feedback = 'Testing'

    assert(@feedback.save)

    assert(@feedback.destroy)
  end

  def test_associations
    assert_kind_of(Participant, feedbacks(:first).participant)
  end
end
