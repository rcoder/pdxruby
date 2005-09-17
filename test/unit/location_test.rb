require File.dirname(__FILE__) + '/../test_helper'

class LocationTest < Test::Unit::TestCase
  fixtures :locations

  def setup
    @location = Location.find(1)
  end

  # Replace this with your real tests.
  def test_truth
    assert_kind_of Location,  @location
  end
end
