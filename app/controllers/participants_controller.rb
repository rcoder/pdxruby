class ParticipantsController < ApplicationController
  def index
    list
    render :action => 'list'
  end

  def list
    @participant_pages, @participants = paginate :participant, :per_page => 10
  end

  def show
    @participant = Participant.find(params[:id])
  end

  def new
    @participant = Participant.new
    @event = Event.find(params[:event])
  end

  def create
    @participant = Participant.new(params[:participant])
    @participant.member = session[:member]
    @participant.event = Event.find(params[:event][:id].to_i)
    if @participant.save
      flash[:notice] = 'Thank you for signing up'
      redirect_to :controller => 'events', :action => 'show', :id => params[:event][:id]
    else
      render :action => 'new'
    end
  end

  def edit
    @participant = Participant.find(params[:id])
  end

  def update
    @participant = Participant.find(params[:id])
    if @participant.update_attributes(params[:participant])
      flash[:notice] = 'Participant was successfully updated.'
      redirect_to :action => 'show', :id => @participant
    else
      render :action => 'edit'
    end
  end

  def destroy
    Participant.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
