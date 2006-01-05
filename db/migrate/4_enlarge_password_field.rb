class EnlargePasswordField < ActiveRecord::Migration
  def self.up
     puts "Expanding password field to 40 chars for SHA1"
     # change_column doesn't work for an unknown reason
     # this is okay, since changing hash functions is irreversible anyway
     remove_column :members, :password
     add_column :members, :password, :string, :limit => 40
  end

  def self.down
     puts "Contracting password field to 32 chars for MD5"
     remove_column :members, :password
     add_column :members, :password, :string, :limit => 32
  end
end
