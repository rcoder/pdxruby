-- create.sql
-- 
-- purpose: creates the db structure for the 'cat herder'

-- each event
CREATE TABLE events (
	id SERIAL,
	member_id INT,		-- the owner
	location_id INT,
	name VARCHAR(64),
	starts_at TIMESTAMP,
	ends_at TIMESTAMP,
	agenda TEXT,
	status VARCHAR(32),
	minutes TEXT,		-- notes
	created_at TIMESTAMP,
	PRIMARY KEY (id)
);	

-- each location
CREATE TABLE locations (
	id SERIAL,
	name VARCHAR(64),
	address TEXT,
	homepage VARCHAR(256),
	created_at TIMESTAMP,
	PRIMARY KEY (id)
);

-- each member
CREATE TABLE members (
	id SERIAL,
	name VARCHAR(128),
	email VARCHAR(128),
	password HASH,
	feed_url VARCHAR(256),
	about TEXT,
	created_at TIMESTAMP,
	PRIMARY KEY (id)
);

-- one member has many participations
CREATE TABLE participants (
	id SERIAL,
	member_id INT,
	event_id INT,
	attending VARCHAR(32),
	comments TEXT,
	created_at TIMESTAMP,
	PRIMARY KEY (id)
);

-- one participation has many feedbacks
CREATE TABLE feedbacks (
	id SERIAL,
	participant_id INT,
	feedback TEXT,
	created_at TIMESTAMP,
	PRIMARY KEY (id)
); 
