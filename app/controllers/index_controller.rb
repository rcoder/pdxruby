class IndexController < ApplicationController
  def index
    @upcoming_events = Event.find :all, :conditions => "starts_at > '#{Time.now}' AND status = '#{Event::EVENT_STATUS[:active]}'" 
  end
end
