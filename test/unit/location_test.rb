require File.dirname(__FILE__) + '/../test_helper'

class LocationTest < Test::Unit::TestCase
  fixtures :locations

  def setup
    @location = Location.find(1)
    @location_two = Location.find(2)
  end

  # Replace this with your real tests.
  def test_truth
    assert_kind_of Location,  @location
  end
  # Start CRUD
  def test_create
    new_location = Location.new
    new_location.id = 3
    new_location.name = "Joe's Diner"
    new_location.address = "1000 Burnt Food Ct"
    new_location.homepage = "http://joe.diner.com"
    new_location.created_at = "Time.now"
    assert new_location.save
    assert_equal 3, Location.find(3).id
    assert_equal "Joe's Diner", Location.find(3).name
  end
  
  def test_read
    assert_equal "Somewhere Under the Rainbow", @location.name
    assert_not_equal "Another Place", @location.name
    assert_equal "My backyard", @location_two.name  
  end
  
  def test_update
    assert_equal "My backyard", @location_two.name
    @location_two.name = "My Pool"
    @location_two.address = "100 Main Street, USA"
    assert @location_two.save
    assert_equal "My Pool", @location_two.name
    assert_not_equal "001 Main Street, USA", @location_two.address
  end
  
  def test_delete
    @location_two.destroy
    assert_raise(ActiveRecord::RecordNotFound) { Location.find(@location_two.id) }
  end
  
  # end CRUD Tests

  # Start validation tests
  #   Presence Sub-section
  def test_no_name
    @new_location = Location.new
    @new_location.id = 3
    @new_location.address = "300 South Street"
    @new_location.homepage = "http://www.foo.com"
    assert !@new_location.save
  end
  
  def test_no_address
    @new_location = Location.new
    @new_location.id = 3
    @new_location.name = "Woodstock"
    @new_location.homepage = "http://www.foo.com"
    assert !@new_location.save
  end

  #   Uniqueness Sub-section
  def test_dupe_name
    @new_location = Location.new
    @new_location.id = 3
    @new_location.name = "My backyard"
    @new_location.address = "100 Main Street, USA"
    @new_location.homepage = "http://www.foo.com"
    assert !@new_location.save
  end
  
  def test_dupe_address
    @new_location = Location.new
    @new_location.id = 3
    @new_location.name = "OSCON 2010"
    @new_location.address = "001 Main Street, USA"
    @new_location.homepage = "http://www.foo.com"
    assert !@new_location.save
  end

  #   Length Sub-section
  def test_very_long_name
    @new_location = Location.new
    @new_location.id = 3
    @new_location.name = "The greatest event the world has ever seen, only $15.99 for a ticket for two"
    @new_location.address = "1 Country Rd, USA"
    @new_location.homepage = "http://www.foo.com"
    assert !@new_location.save
  end
  
  def test_very_long_homepage
    @new_location = Location.new
    @new_location.id = 3
    @new_location.name = "Geocities Meetup"
    @new_location.address = "120 West Beer St, Portland"
    @new_location.homepage = "http://" + "pwn." * 100 + "geocities.com/u484"
    assert !@new_location.save
  end

  #   Invalid Formats Sub-section
  def test_invalid_homepage_format
    @new_location = Location.new
    @new_location.id = 3
    @new_location.name = "Geocities Meetup"
    @new_location.homepage = "geocities.com/u484" # missing http://
    assert !@new_location.save
  end

  # End validation tests
end
