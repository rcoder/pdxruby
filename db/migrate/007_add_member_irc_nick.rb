class AddMemberIrcNick < ActiveRecord::Migration
  def self.up
    add_column :members, :irc_nick, :string, :limit => 128
  end

  def self.down
    remove_column :members, :irc_nick
  end
end
