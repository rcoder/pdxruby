class InitialSchema < ActiveRecord::Migration
	def self.up
		create_table "articles", :force => true do |t|
			t.column "member_id", :integer
			t.column "modified_at", :datetime
			t.column "title", :string, :limit => 256
			t.column "content", :text
			t.column "link", :string, :limit => 256
		end

		create_table "events", :force => true do |t|
			t.column "member_id", :integer
			t.column "location_id", :integer
			t.column "name", :string, :limit => 64
			t.column "starts_at", :datetime
			t.column "ends_at", :datetime
			t.column "agenda", :text
			t.column "status", :string, :limit => 32
			t.column "minutes", :text
			t.column "created_at", :datetime
		end

		create_table "feedbacks", :force => true do |t|
			t.column "participant_id", :integer
			t.column "feedback", :text
			t.column "created_at", :datetime
		end

		create_table "locations", :force => true do |t|
			t.column "name", :string, :limit => 64
			t.column "address", :text
			t.column "homepage", :string, :limit => 256
			t.column "created_at", :datetime
		end

		create_table "members", :force => true do |t|
			t.column "name", :string, :limit => 128
			t.column "email", :string, :limit => 128
			t.column "password", :string, :limit => 32
			t.column "feed_url", :string, :limit => 256
			t.column "about", :text
			t.column "created_at", :datetime
		end

		create_table "participants", :force => true do |t|
			t.column "member_id", :integer
			t.column "event_id", :integer
			t.column "attending", :string, :limit => 32
			t.column "comments", :text
			t.column "created_at", :datetime
		end
	end

	def self.down
		drop_table :articles
		drop_table :events
		drop_table :feedbacks
		drop_table :locations
		drop_table :members
		drop_table :participants
	end
end
