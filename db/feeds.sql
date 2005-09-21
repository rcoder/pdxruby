
-- member rss feed articles
CREATE TABLE articles (
  id SERIAL,
  member_id INT,
  modified_at TIMESTAMP,
  title VARCHAR(256),
  content TEXT,
  link VARCHAR(256),
  PRIMARY KEY (id)
);
