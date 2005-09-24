class FeedbacksController < ApplicationController
  def index
    list
    render :action => 'list'
  end

  def list
    @feedback_pages, @feedbacks = paginate :feedback, :per_page => 10
  end

  def show
    @feedback = Feedback.find(params[:id])
  end

  def new
    @feedback = Feedback.new
    @participant = Participant.find(
    	:first,
    	:conditions => [
    		'member_id = ? and event_id = ?', 
    		session[:member].id, 
    		params[:event]
    	]
    )
  end

  def create
    @feedback = Feedback.new(params[:feedback])
    @feedback.participant = Participant.find(params[:participant][:id])
    if @feedback.save
      flash[:notice] = 'Feedback was successfully created.'
      redirect_to :controller => 'events', 
      	:action => 'show', 
      	:id => @feedback.participant.event.id
    else
      render :action => 'new'
    end
  end

  def edit
    @feedback = Feedback.find(params[:id])
  end

  def update
    @feedback = Feedback.find(params[:id])
    if @feedback.update_attributes(params[:feedback])
      flash[:notice] = 'Feedback was successfully updated.'
      redirect_to :action => 'show', :id => @feedback
    else
      render :action => 'edit'
    end
  end

  def destroy
    Feedback.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
