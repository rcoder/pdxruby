class IndexController < ApplicationController
  def index
    @upcoming_events = Event.find_upcoming(UPCOMING_EVENT_LIMIT)
    @recent_events   = Event.find_recent(RECENT_EVENT_LIMIT)
    @member_articles = Article.find(:all, :limit => RECENT_ARTICLE_LIMIT, :order => 'modified_at DESC')
  end
end
