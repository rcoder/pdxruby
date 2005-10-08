require 'digest/md5'

class HashMemberPasswords < ActiveRecord::Migration
  def self.up
    print "Hashing member passwords... "
    Member.find(:all).each { |m|
      print "#{m.name}, "
      m.password = Digest::MD5.hexdigest(m.password)
      m.save_without_validation
    }
    puts "done!"
  end

  def self.down
    raise "This migration cannot be reversed!"
  end
end
