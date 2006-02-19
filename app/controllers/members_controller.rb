class MembersController < ApplicationController
  
  before_filter :authenticate, :except => [ :login, :new, :create, :reset ]
  before_filter :member_is_this_member!, :only => [ :edit, :update ]
  before_filter :member_exists!, :only => [ :show ]
  
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

  def new
    @member = Member.new
  end

  def create
    params[:member][:password] = params[:password]
    if !check_passwords_match
      flash[:notice] = 'Passwords do not match'
      render :action => 'new'
      return false
    end
    # enhash password before insertion
    params[:member][:password] = Digest::SHA1.hexdigest(params[:member][:password])
    # create a new member from given values
    @member = Member.new(params[:member])
    if @member.save
      begin
        save_mugshot params[:image_file]
      rescue StandardError => message
        flash[:notice] = message
        redirect_to :action => 'edit', :id => @member
        return false
      end
      flash[:notice] = 'Member was successfully created.'
      MailBot::deliver_signup_message(self, @member)
      session[:member] = @member
      redirect_to :action => 'show', :id => @member.id
      return false
    else
      flash[:notice] = "Sorry, but the member couldn't be created for some reason."
      render :action => 'new'
      return false
    end
  end

  def edit
    @member = Member.find(params[:id])
  end

  def update
    params[:member][:password] = params[:password]
    @member = Member.find(params[:id])
    if !check_passwords_match
      flash[:notice] = 'Passwords do not match'
      render :action => 'edit'
      return false
    end
    # enhash the password only if it came in as a parameter, and is longer than 0
    # this will avoid enhashing a hash and enhashing ''
    if params[:member][:password].length > 0
      params[:member][:password] = Digest::SHA1.hexdigest(params[:member][:password])
    else
      params[:member][:password] = @member.password
    end
    if @member.update_attributes(params[:member])
      begin
        save_mugshot params[:image_file]
      rescue StandardError => message
        flash[:notice] = message
        redirect_to :action => 'edit', :id => @member
        return false
      end
      flash[:notice] = 'Member was successfully updated.'
      redirect_to :action => 'show', :id => @member
      return false
    else
      flash[:notice] = "Sorry, but the member profile couldn't be updated for some reason."
      render :action => 'edit'
      return false
    end
  end
  
  def login
    if request.get?
      if session[:member]
        redirect_to :action => 'show', :id => session[:member]
        return false
      end
    elsif request.post?
      email = params[:member][:email]
      password = Digest::SHA1.hexdigest(params[:member][:password])
      member = Member.find_by_email(email)
      if member.nil?
        flash[:notice] = "That member doesn't exist."
      else
        if password != member.password
          flash[:notice] = "Wrong password."
        else
          if member.password_reset != nil
            member.password_reset = nil
            if member.save
              flash[:notice] = "Someone has requested a password reset
                on your account.  If this was you and you received an
                e-mail, great.  If not, no worries -- you just foiled
                them.  Make sure your e-mail address is correct."
            else
              flash[:notice] = "Someone has requested a password reset
                on your account and there was an error in the database.
                This may be a security risk."
            end
          end
          session[:member] = member
          redirect_to :action => 'show', :id => member
          return false
        end
      end
    end
  end

  def reset
    if authenticated?
      flash[:notice] = 'You are logged in.  You may change your password below.'
      redirect_to :action => 'edit', :id => session[:member].id
    else
      if request.get?
        unless params[:id] == nil
          # XXX need to refactor this anti-fishing stuff into a helper?
          member = Member.find_by_id(params[:id])
          if member.nil?
            flash[:notice] = "double bah!!"
          elsif member.password_reset == nil
            flash[:notice] = "bah"
          else
            return true
          end
          redirect_to :action => 'login'
          return false
        end
        return true
      elsif request.post?
        if params[:id] == nil
          # request reset stage
          email = params[:member][:email]
          member = Member.find_by_email(email)
          if member.nil?
            flash[:notice] = "That member doesn't exist."
            redirect_to :action => 'login'
            return false
          end
          # generate temporary password
          member.password_reset = Digest::SHA1.hexdigest('foo')
          unless member.save
            flash[:notice] = "something isn't working"
            redirect_to :action => 'login'
            return false
          end
          # fire-off an e-mail

          flash[:notice] = "You should receive an e-mail shortly.  Please
            follow its instructions."
          redirect_to :action => 'login'
          # if that fails, back out

        else
          # this is the validate-reset stage
          # XXX need to refactor this anti-fishing stuff into a helper?
          member = Member.find_by_id(params[:id])
          if member.nil?
            flash[:notice] = "double bah!!"
            redirect_to :action => 'login'
            return false
          elsif member.password_reset == nil
            flash[:notice] = "bah"
            return false
          end
          # now check
          password_reset = Digest::SHA1.hexdigest(params[:member][:reset])
          if password_reset == member.password_reset
            # ok
            member.password = member.password_reset
            member.password_reset = nil
            member.save or raise "db"
            flash[:notice] = "please change your password"
            session[:member] = member
            redirect_to :action => 'edit', :id => member
            return true
          else
            flash[:notice] = "bah"
            member.password_reset = nil
            member.save or raise "db"
            return false
          end
        end # id or not
      end
        return false
    end
  end
  
  def logout
    reset_session
    flash[:notice] = "You are logged out."
    redirect_to :action => 'login'
  end
  
  private
  
  def check_passwords_match
    if params[:member][:password] != params[:verify_password]
      return false
    end
    return true
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
