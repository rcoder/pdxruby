class EventsController < ApplicationController
  before_filter :login_required, :only => [ :edit, :create, :new, :destroy ]

  def index
    list
    render :action => 'list'
  end

  def list
    @event_pages, @events = paginate :event, :per_page => 10
  end

  def show
    @event = Event.find(params[:id])
  end

  def new
    @event = Event.new
    @location = Location.new
  end

  def create
    @event = Event.new(params[:event])
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
    
    if @event.save
      flash[:notice] = 'Event was successfully created.'
      redirect_to :action => 'list'
    else
      @location = Location.new
      render :action => 'new'
    end
  end

  def edit
    @event = Event.find(params[:id])
    @location = @event.location
  end

  def update
    @event = Event.find(params[:id])
    if @event.update_attributes(params[:event])
      flash[:notice] = 'Event was successfully updated.'
      redirect_to :action => 'show', :id => @event
    else
      render :action => 'edit'
    end
  end

  def destroy
    Event.find(params[:id]).destroy
    redirect_to :action => 'list'
  end

  def login_required
    if session[:member].nil?
      flash[:notice] = "Must be logged in to edit events"
      redirect_to :action => "index" and return
    end    
  end

end
