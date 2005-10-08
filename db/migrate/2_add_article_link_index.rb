class AddArticleLinkIndex < ActiveRecord::Migration
  def self.up
    puts "Creating index articles_link_index on column articles.link"
    execute "CREATE INDEX articles_link_index on articles (link)"
  end

  def self.down
    puts "Deleting index articles_link_index from column articles.link"
    execute "DROP INDEX articles_link_index"
  end
end
