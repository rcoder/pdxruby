class ParticipantsController < ApplicationController
  def index
    list
    render :action => 'list'
  end

  def list
    @participants = Participant.paginate(:page => params[:page])
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
      MailBot::deliver_rsvp_message(self, @participant) if @participant.is_attending?
      redirect_to :controller => 'events', :action => 'show', :id => params[:event][:id]
    else
      render :action => 'new'
    end
  end

  def edit
    @participant = Participant.find(params[:id])
    if !member_is_this_member? @participant.member_id
      flash[:notice] = "Sorry, That's not yours."
      redirect_to :controller => 'members', :action => 'show', :id => session[:member].id
    end
  end

  def update
    @participant = Participant.find(params[:id])
    if !member_is_this_member? @participant.member_id
      flash[:notice] = "Sorry, That's not yours."
      redirect_to :controller => 'members', :action => 'show', :id => session[:member].id
    end
    if @participant.update_attributes(params[:participant])
      flash[:notice] = 'Participant was successfully updated.'
      MailBot::deliver_rsvp_message(self, @participant) if @participant.is_attending?
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
