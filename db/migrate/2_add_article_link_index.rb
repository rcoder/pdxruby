class AddArticleLinkIndex < ActiveRecord::Migration
  def self.up
    puts "Creating index articles_link_index on column articles.link"
    add_index :articles, :link
  end

  def self.down
    puts "Deleting index articles_link_index from column articles.link"
    remove_index :articles, :link
  end
end
