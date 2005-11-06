require File.dirname(__FILE__) + '/../test_helper'

class MemberTest < Test::Unit::TestCase
  fixtures :members

  def setup
    @member_bob = Member.find(1)
    @member_sue = Member.find(2)
  end

  # Replace this with your real tests.
  def test_truth
    assert_kind_of Member,  @member_bob
  end
  
  # Start CRUD
  def test_create
    new_member = Member.new
    new_member.id = 3
    new_member.name = "Joe"
    new_member.email = "joe@joes.diner.com"
    new_member.password = Digest::MD5.hexdigest('joe')
    new_member.feed_url = "http://feed.joes.diner.com/feed"
    new_member.about = "Joe is a young las who likes to cook food"
    new_member.created_at = "Time.now"
    assert new_member.save
    assert_equal 3, Member.find(3).id
    assert_equal "Joe", Member.find(3).name
  end
  
  def test_read
    assert_equal "Bob", @member_bob.name
    assert_not_equal "Sue", @member_bob.name
    assert_equal Digest::MD5.hexdigest('abc'), @member_bob.password
    assert_not_equal 'abc', @member_bob.password
    assert_equal "Sue", @member_sue.name  
  end
  
  def test_update
    assert_equal "Bob", @member_bob.name
    @member_bob.name = "Billy Bob"
    @member_bob.about = "Bob finally got his name legally changed to Billy Bob"
    assert @member_bob.save
    assert_equal "Billy Bob", @member_bob.name
    assert_not_equal "something", @member_bob.about
  end
  
  def test_delete
    @member_bob.destroy
    assert_raise(ActiveRecord::RecordNotFound) { Member.find(@member_bob.id) }
  end
  
  # end CRUD Tests

  # Start validation tests
  #   Presence Sub-section
  def test_no_name
    @new_member = Member.new
    @new_member.id = 3
    @new_member.email = "noname@name.org"
    @new_member.password = Digest::MD5.hexdigest('foo')
    assert !@new_member.save
  end
  
  def test_no_email
    @new_member = Member.new
    @new_member.id = 3
    @new_member.name = "anon"
    @new_member.password = Digest::MD5.hexdigest('foo')
    assert !@new_member.save
  end

  def test_no_password
    @new_member = Member.new
    @new_member.id = 3
    @new_member.name = "Mr. Insecure"
    @new_member.email = "nilpassword@password.org"
    assert !@new_member.save
  end

  #   Uniqueness Sub-section
  def test_dupe_email_address
    @new_member = Member.new
    @new_member.id = 3
    @new_member.name = "Email Leecher"
    @new_member.email = "bob@bob.com"
    @new_member.password = Digest::MD5.hexdigest('tehe')
    assert !@new_member.save
  end

  #   Length Sub-section
  def test_very_long_name
    @new_member = Member.new
    @new_member.id = 3
    @new_member.name = "This is a very long name that is passed in to try to overflow a buffer or maybe with a bit of SQL injection sent in to wreck havoc on the database and should be stopped, Jr"
    # ^ Poor attempt at some humor ^    
    @new_member.email = "sql@l33tcRackerz.com"
    @new_member.password = Digest::MD5.hexdigest('l33t')
    assert !@new_member.save
  end
  
  def test_very_long_email
    @new_member = Member.new
    @new_member.id = 3
    @new_member.name = "Mike"
    @new_member.email = "abcdefghijklmnopqrstuvwxy_and_z@a.b.c.d.e.f.g.h.i.j.k.l.m.n.o.p.q.r.s.t.u.v.w.x.y.and.z.dynamic.aol.com"
    # ^ Poor attempt at some humor ^
    @new_member.password = Digest::MD5.hexdigest('aol')
    assert !@new_member.save
  end

  def test_very_long_feed
    @new_member = Member.new
    @new_member.id = 3
    @new_member.name = "Url Happy"
    @new_member.email = "feeds@feeder.com"
    @new_member.feed_url = "http://" + "feed" * 100 + "google.com/atom"
    @new_member.password = Digest::MD5.hexdigest('atom')
    assert !@new_member.save
  end
  #   Invalid Formats Sub-section
  def test_invalid_email_format
    @new_member = Member.new
    @new_member.id = 3
    @new_member.name = "Donnie"
    @new_member.email = "donnie@AOL"
    @new_member.password = Digest::MD5.hexdigest('AoL')
    assert !@new_member.save
  end

  def test_invalid_feed_format
    @new_member = Member.new
    @new_member.id = 3
    @new_member.name = "Invalid Feed"
    @new_member.email = "feeds@feeder.com"
    @new_member.feed_url = "feed.feeder.com" # missing http://
    @new_member.password = Digest::MD5.hexdigest('atom')
    assert !@new_member.save
  end
  # End validation tests
end
