# The filters added to this controller will be run for all controllers in the application.
# Likewise will all the methods added be available for all controllers.
class ApplicationController < ActionController::Base

  def authenticate
    unless session[:member] && Member.find(session[:member].id)
      reset_session
      redirect_to :controller => 'members', :action => 'login'
    end
  end
  
end