require File.dirname(__FILE__) + '/../test_helper'

class MemberTest < Test::Unit::TestCase
  fixtures :members

  def setup
    @member = Member.find(1)
  end

  # Replace this with your real tests.
  def test_truth
    assert_kind_of Member,  @member
  end
end
