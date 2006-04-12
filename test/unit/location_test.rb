require File.dirname(__FILE__) + '/../test_helper'

class LocationTest < Test::Unit::TestCase
  fixtures :locations

  def setup
    @location = Location.new

    @location.name = "Joe's Diner"
    @location.address = "1000 Burnt Food Ct"
    @location.homepage = "http://joe.diner.com"
  end

  def test_create_read_update_delete
    assert(@location.save)

    read_location = Location.find_by_name "Joe's Diner"

    assert_equal(@location.name, read_location.name)

    @location.name = "My Pool"
    @location.address = "100 Main Street, USA"

    assert(@location.save)

    assert(@location.destroy)
  end

  def test_associations
    assert_kind_of(Array, locations(:first).events)
  end

  def test_validates_presence_of_name
    @location.name = nil

    assert_equal(false, @location.save)
  end

  def test_validates_presence_of_address
    @location.address = nil

    assert_equal(false, @location.save)
  end

  def test_validates_uniqueness_of_name
    @location.name = "My backyard"

    assert_equal(false, @location.save)
  end

  def test_validates_uniqueness_of_address
    @location.address = "001 Main Street, USA"

    assert_equal(false, @location.save)
  end

  def test_validates_length_of_name
    @location.name = "The greatest event the world has ever seen, " +
      "only $15.99 for a ticket for two"

    assert_equal(false, @location.save)
  end

  def test_validates_length_of_homepage
    @location.homepage = "http://" + "pwn." * 100 + "geocities.com/u484"

    assert_equal(false, @location.save)
  end

  def test_validates_format_of_homepage
    # missing http://
    @location.homepage = "geocities.com/u484"

    assert_equal(false, @location.save)
  end
end
