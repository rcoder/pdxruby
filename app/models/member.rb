class Member < ActiveRecord::Base
  has_many :events
  has_many :participants
  
  validates_presence_of :name
  validates_presence_of :email
  validates_presence_of :password

  validates_uniqueness_of :email

  validates_length_of :name, :maximum => 128
  validates_length_of :email, :maximum => 128
  validates_length_of :feed_url, :maximum => 256

  validates_each :email do |rec, attr|
    re = Regexp.new(RE::EMAIL)
    unless re =~ rec.send(attr)
      rec.errors.add attr, "looks awry. An email address should look something like user@host.tld."
    end
  end

  validates_each :feed_url do |rec, attr|
    re = Regexp.new(RE::URL)
    url = rec.send(attr)
    unless url.nil? or url == '' or re =~ url
      rec.errors.add attr, "looks awry. A URL should look something like http://som/ewh/ere."
    end
  end

end
