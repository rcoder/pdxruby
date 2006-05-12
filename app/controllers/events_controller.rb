class EventsController < ApplicationController
  before_filter :authenticate, :only => [ :edit, :create, :new, :claim ]
  before_filter :member_is_owner, :only => [ :edit, :destroy, :release ]
 
  def index
    list
    render :action => 'list'
  end

  def list
    @event_pages, @events = paginate :event, :per_page => 10, :order_by => 'starts_at DESC'
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
      MailBot::deliver_change_message(self, @event) unless params[:trivial]
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
  
  def release
    @event = Event.find(params[:id])
    if session[:member].id != @event.member_id
      flash[:notice] = "Only an event owner can release it."
      redirect_to :action => 'list'
      return
    end
    @event.member = nil
    if @event.save
      flash[:notice] = "Event released."
    else
      flash[:notice] = "Failed to release event."
    end
    redirect_to :action => 'list'
  end
  
  def claim
    @event = Event.find(params[:id])
    unless @event.unclaimed?
      flash[:notice] = "This event already has an owner. They must release it before it can be claimed."
      redirect_to :action => 'show', :id => @event.id
      return
    end
    @event.member = session[:member]
    if @event.save
      flash[:notice] = "Event ownership claimed. Thank you!"
    else
      flash[:notice] = "Failed to claim event."
    end
    redirect_to :action => 'show', :id => @event.id
  end
  
  ICAL_EVENT_LIMIT = 100
  def ical
     @headers['content-type'] = 'text/plain'
     @events = Event.find_upcoming(ICAL_EVENT_LIMIT)
     render_without_layout
  end
  
  private
  
  def member_is_owner
    if !member_is_this_member? Event.find(params[:id]).member.id
      flash[:notice] = "Only the owner can edit or remove events."
      redirect_to :action => 'list'
      return false
    end
  end
end
