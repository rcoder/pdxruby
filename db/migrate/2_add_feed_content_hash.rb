class AddFeedContentHash < ActiveRecord::Migration
  def self.up
    puts "Adding new char(32) column articles.content_hash"
    execute "ALTER TABLE articles ADD COLUMN content_hash CHARACTER(32)" 
  end

  def self.down
    puts "Removing column articles.content_hash"
    remove_column :articles, :content_hash
  end
end
