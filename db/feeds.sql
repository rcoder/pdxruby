
-- member rss feed articles
CREATE TABLE articles (
  id SERIAL,
  member_id INT,
  modified_at TIMESTAMP,
  title VARCHAR(256),
  content TEXT,
  link VARCHAR(256),
  content_hash CHAR(32),
  PRIMARY KEY (id)
);

CREATE INDEX articles_link_index on articles (link);
