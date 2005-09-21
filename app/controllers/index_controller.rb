class IndexController < ApplicationController
  RECENT_ARTICLE_LIMIT = 5
  UPCOMING_EVENT_LIMIT = 5
  RECENT_EVENT_LIMIT   = 5
  
  def index
    @upcoming_events = Event.find_upcoming(UPCOMING_EVENT_LIMIT)
    @recent_events   = Event.find_recent(RECENT_EVENT_LIMIT)
    @member_articles = Article.find(
      :all, 
      :order_by => 'modified_at desc', 
      :limit => RECENT_ARTICLE_LIMIT
    )
  end
end
