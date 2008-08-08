class MembersController < ApplicationController

  before_filter :authenticate, :except => [ :login, :reset, :update, :register ]
  #  before_filter :member_is_this_member!, :only => [ :edit ]
  #  before_filter :member_exists!, :only => [ :show ]

  require 'imageops'
  require 'digest/sha1'

  def index
    redirect_to :action => 'login'
  end

  def show
    @member = Member.find(params[:id])
    @participations = Participant.find_upcoming(params[:id])
  end

  def list
    @members = Member.find :all, :order => "name"
  end

  def update
    @member = Member.find_by_id(params[:id]) || Member.new(params[:member])
    if request.post?
      @member.attributes = params[:member]
      if @member.save
        begin
          save_mugshot params[:image_file]
        rescue StandardError => message
          flash[:notice] = message
        end
        flash[:notice] = "Successfully updated."
        session[:member] = @member
        redirect_to home_url
      else
        flash[:notice] = "Sorry, but the account could not be updated/created for some reason."
      end
    end
  end

  def login
    unless request.post?
      render :template => "members/login"
      return false
    end

    member = Member.find_by_email(params[:member][:email])

    if member.nil?
      flash[:notice] = "That member doesn't exist."
      return false
    elsif params[:request_reset] != nil
      tmp_pass = member.reset_password
      if (send_password_reset_email(member, tmp_pass) and member.save)
        flash[:notice] = "Your new password has been emailed to you. Please check your email."
      else
        flash[:notice] = "Could not reset your password. Try again later."
      end
      return false
    else
      logger.debug "comparing passwords"
      if member.compare_password(params[:member][:password])
        logger.debug "passwords don't match!"
        flash[:notice] = "Incorrect login."
        return false
      end
    end
    logger.debug "successful login for #{member[:name]}"
    session[:member] = member
    redirect_to session[:return_to] ? session[:return_to] : home_url
  end

  def logout
    reset_session
    redirect_to home_url
  end

  private

  def send_password_reset_email(member, new_password)
    return MailBot::deliver_reset_password(self, member, new_password)
  end

  def member_exists!
    requested_member = member_exists? params[:id]
    if requested_member.nil?
      flash[:notice] = "That Member Doesn't Exist. Try Again."
      redirect_to :action => 'list'
      return false
    end
  end

  def member_is_this_member!
    if !member_is_this_member? params[:id]
      flash[:notice] = "No Peeking."
      redirect_to :action => 'list'
      return false
    end
  end

  def save_mugshot(image_file)
    if (image_file.nil?) or (image_file.size == 0)
      return
    end

    filename = RAILS_ROOT + "/public/images/members/" + @member.id.to_s + ".jpg"
    # make sure filetype is okay
    if image_file.content_type.scan(/image\/jpeg/).empty?
      raise "Mugshot must be of type image/jpeg. (not " + image_file.content_type + ")"
      return
    end

    # make sure it is less than 100k
    if image_file.size > 100000
      raise "Mugshot cannot be larger than 100k bytes."
      return
    end

    # if the file exists already, delete it
    if File.exist?(filename)
      File.unlink(filename)
    end
    file = File.new(filename,File::CREAT|File::WRONLY)
    file.write(params[:image_file].read)
    file.close

    # you can comment out these three lines if you don't want to do dynamic resizing
    ImageOps.resize(filename, "64x64")
  end

end

# vi:ts=2:sw=2:et
