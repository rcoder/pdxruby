class EventsController < ApplicationController
  before_filter :authenticate, :only => [ :edit, :create, :new, :destroy ]
 
  def index
    list
    render :action => 'list'
  end

  def list
    @event_pages, @events = paginate :event, :per_page => 10
  end

  def show
    @event = Event.find(params[:id])
    
    @participants = @event.participants

    @participants_by_status = HashWithIndifferentAccess.new
    @participants_by_status[:yes]   = Array.new
    @participants_by_status[:no]    = Array.new
    @participants_by_status[:maybe] = Array.new
    @participants.each do |participant|
      @participants_by_status[participant.attending.to_sym] << participant
    end

  end

  def new
    @event = Event.new
    @event.starts_at = Time.now
    @event.ends_at = @event.starts_at + (60*60)
    @location = Location.new
  end

  def create
    @event = Event.new(params[:event])
    @event.member = session[:member]
    if params[:event][:location_id] == ""
      location = Location.find_by_name(params[:location][:name])
      if location.nil?
        location = Location.new(params[:location]) 
        unless location.save
          @location = location
          render :action => 'new' and return
        end
      end
      @location = location
    else
      @location = Location.find(params[:event][:location_id].to_i)
    end
    
    @event.location = @location
    @event.active!
    
    if @event.save
      flash[:notice] = 'Event was successfully created.'
      Member.find(:all) do |member| 
         MailBot::deliver_new_event_message(self, @event, member)
      end
      redirect_to :action => 'list'
    else
      @location = Location.new
      render :action => 'new'
    end
  end

  def edit
    @event = Event.find(params[:id])
    if session[:member].id != @event.member_id
    	flash[:notice] = "Sorry. You do not own this event."
	redirect_to :action => 'list'
	return
    end
    @location = @event.location
  end

  def update
    @event = Event.find(params[:id])
    if session[:member].id != @event.member_id
    	flash[:notice] = "Sorry. You do not own this event."
	redirect_to :action => 'list'
	return
    end
    if @event.update_attributes(params[:event])
      flash[:notice] = 'Event was successfully updated.'
      MailBot::deliver_change_message(self, @event)
      redirect_to :action => 'show', :id => @event
    else
      render :action => 'edit'
    end
  end

  def destroy
    @event = Event.find(params[:id])
    if session[:member].id != @event.member_id
      flash[:notice] = "Sorry. You do not own this event."
	    redirect_to :action => 'list'
    	return
    end
    @event.destroy
    redirect_to :action => 'list'
  end

  def cancel
    @event = Event.find(params[:id])
    if session[:member].id != @event.member_id
      flash[:notice] = "Sorry. You do not own this event."
      redirect_to :action => 'list'
      return
    end
    @event.cancel!
    if @event.save
      flash[:notice] = "Event cancelled."
      MailBot::deliver_cancel_message(self, @event)
    else
      flash[:notice] = "Failed to cancel event."
    end
    redirect_to :action => 'list'
  end
end
