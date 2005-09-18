require 'pp'

class MembersController < ApplicationController
  
  before_filter :authenticate, :except => [ :login, :new ]
  before_filter :verify, :only => [ :show, :edit, :update ]
  
  def index
    login
    render :action => 'login'
  end

  def show
    @member = Member.find(params[:id])
  end

  def new
    @member = Member.new
  end

  def create
    @member = Member.new(params[:member])
    if @member.save
      flash[:notice] = 'Member was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @member = Member.find(params[:id])
  end

  def update
    @member = Member.find(params[:id])
    if @member.update_attributes(params[:member])
      flash[:notice] = 'Member was successfully updated.'
      redirect_to :action => 'show', :id => @member
    else
      render :action => 'edit'
    end
  end
  
  def login
    if request.get?
      if session[:member]
        redirect_to :action => 'show', :id => session[:member]
      end
    elsif request.post?
      email = params[:member][:email]
      password = params[:member][:password]
      member = Member.find_by_email(email)
      if member.nil?
        flash[:notice] = "That member doesn't exist."
      else
        if password != member.password
          flash[:notice] = "Wrong password."
        else
          session[:member] = member
          redirect_to :action => 'show', :id => member
        end
      end
    end
  end
  
  def logout
    reset_session
    flash[:notice] = "You are logged out."
    redirect_to :action => 'login'
  end
  
  private
  
  def verify
    begin
      requested_member = Member.find(params[:id])
    rescue
      render_text "That member does not exist."
      return false
    end
    if requested_member != session[:member]
      redirect_to :action => 'logout'
    end
  end
    
end
