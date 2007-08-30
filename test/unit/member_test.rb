require File.dirname(__FILE__) + '/../test_helper'
require 'digest/sha1'

class MemberTest < Test::Unit::TestCase
  fixtures :members

  def setup
    @member = Member.new

    @member.name = "Joe"
    @member.email = "joe@joes.diner.com"
    @member.password = 'joe'
    @member.password_confirmation = 'joe'
    @member.feed_url = "http://feed.joes.diner.com/feed"
    @member.about = "Joe is a young lad who likes to cook food"
  end

  def test_create_read_update_delete
    assert(@member.save)

    read_member = Member.find_by_email "joe@joes.diner.com"

    assert_equal(@member.name, read_member.name)

    @member.name = "Billy Bob"
    @member.about = "Bob finally got his name legally changed to Billy Bob"

    assert(@member.save)

    assert(@member.destroy)
  end

  def test_associations
    assert_kind_of(Array, members(:bob).events)
    assert_kind_of(Array, members(:bob).participants)
  end

  def test_validates_presence_of_name
    @member.name = nil

    assert_equal(false, @member.save)
  end

  def test_validates_presence_of_email
    @member.email = nil

    assert_equal(false, @member.save)
  end

  def test_validates_presence_of_password
    @member.password = nil

    assert_equal(false, @member.save)
  end

  def test_validates_uniqueness_of_email
    @member.email = "bob@bob.com"

    assert_equal(false, @member.save)
  end

  def test_validates_uniqueness_of_irc_nick
    @member.irc_nick = "bob"

    assert_equal(false, @member.save)
  end

  def test_validates_length_of_name
    @member.name = "This is a very long name that is passed in to try to " +
      "overflow a buffer or maybe with a bit of SQL injection sent in to " +
      "wreck havoc on the database and should be stopped, Jr"

    assert_equal(false, @member.save)
  end

  def test_validates_length_of_email
    @member.email = "abcdefghijklmnopqrstuvwxy_and_zplus-a-few-more@" +
      "a.b.c.d.e.f.g.h.i.j.k.l.m.n.o.p.q.r.s.t.u.v.w.x.y.and.z." +
      "and.you.know.its.all.dynamic.aol.com"

    assert_equal(false, @member.save)
  end

  def test_validates_length_of_feed_url
    @member.feed_url = "http://" + "feed" * 100 + "google.com/atom"

    assert_equal(false, @member.save)
  end

  def test_validates_length_of_irc_nick
    @member.irc_nick = 'irc' * 100 + 'nick'

    assert_equal(false, @member.save)
  end

  def test_validates_format_of_email
    @member.email = "donnie@AOL"

    assert_equal(false, @member.save)
  end

  def test_validates_format_of_feed_url
    # missing http://
    @member.feed_url = "feed.feeder.com"

    assert_equal(false, @member.save)
  end
end
