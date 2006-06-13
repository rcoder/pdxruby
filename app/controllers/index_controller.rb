class IndexController < ApplicationController
  def index
    @upcoming_events = Event.find_upcoming(UPCOMING_EVENT_LIMIT)
    @recent_events   = Event.find_recent(RECENT_EVENT_LIMIT)
    @member_articles = Article.find_by_sql "SELECT * FROM articles ORDER BY modified_at DESC LIMIT " + RECENT_ARTICLE_LIMIT.to_s;
  end
end
