class AddPasswordReset < ActiveRecord::Migration
  def self.up
    puts "Adding password_reset field."
    add_column :members, :password_reset, :string, :limit => 40
  end

  def self.down
    puts "Dropping password_reset field."
    remove_column :members, :password_reset
  end
end

