# The filters added to this controller will be run for all controllers in the application.
# Likewise will all the methods added be available for all controllers.
class ApplicationController < ActionController::Base
  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => 'a993580a90b7793c250f29bd2d2672a3'

  # check to see if the current user is logged in as a valid
  # member, if not, log them out
  def authenticate
    unless authenticated?
      reset_session
      session[:return_to] = request.request_uri
      redirect_to :controller => 'members', :action => 'login'
      return false
    end
  end

  def authenticated?
    session[:member] && Member.find(session[:member].id)
  end
  
  # check to see if the currently authenticated member is
  # the member with the given id
  def member_is_this_member?(id)
    requested_member = member_exists? id
    if requested_member.nil?
      return false
    end
    if requested_member != session[:member]
      return false
    end
      return true
  end

  def member_exists?(id)
    begin
      requested_member = Member.find(id)
    rescue
      return nil
    end
    return requested_member
  end
end
