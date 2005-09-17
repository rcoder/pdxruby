require File.dirname(__FILE__) + '/../test_helper'

class FeedbackTest < Test::Unit::TestCase
  fixtures :feedbacks

  def setup
    @feedback = Feedback.find(1)
  end

  # Replace this with your real tests.
  def test_truth
    assert_kind_of Feedback,  @feedback
  end
end
