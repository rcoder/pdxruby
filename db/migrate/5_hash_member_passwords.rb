require 'digest/sha1'

# XXX elw:  does this work if the existing passwords are already md5?

class HashMemberPasswords < ActiveRecord::Migration
  def self.up
    print "Hashing member passwords... "
    Member.find(:all).each { |m|
      print "#{m.name}, "
      m.password = Digest::SHA1.hexdigest(m.password)
      m.save_without_validation
    }
    puts "done!"
  end

  def self.down
    raise "This migration cannot be reversed!"
  end
end
