class Member < ActiveRecord::Base
  attr_accessor :image_file
  
  has_many :events
  has_many :participants
  
  before_save :encrypt_password
  
  validates_presence_of :name
  validates_presence_of :email
  validates_presence_of :password, :on => :create
  validates_presence_of :password_confirmation, :on => :create

  validates_uniqueness_of :email
  validates_uniqueness_of :irc_nick, :allow_nil => true

  validates_length_of :name, :maximum => 128
  validates_length_of :email, :maximum => 128
  validates_length_of :feed_url, :maximum => 256, :allow_nil => true
  validates_length_of :irc_nick, :maximum => 128, :allow_nil => true
  
  validates_confirmation_of :password, 
    :message => "should match confirmation", :on => :create
  
  validates_format_of :email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i
  validates_format_of :feed_url, 
    :with => Regexp.new(RE::URL), 
    :allow_nil => true,
    :if => Proc.new {|member| !member.feed_url.empty?}
   
  # Encrypts some data with the salt.
  def encrypt(password)
    Digest::SHA1.hexdigest(password)
  end
  
  def compare_password(supplied_password)
    encrypted_password = encrypt(supplied_password)
    return (self.password == encrypt_password)
  end
  
  def reset_password
    srand
    chars = (0..9).to_a + ('A'..'Z').to_a + ('a'..'z').to_a
    tmp_pass = (1..20).map {chars[(rand * chars.length).round]}.join('')
    self.password = tmp_pass
    return tmp_pass
  end
  
  private
  
  def encrypt_password
    self.password = encrypt(password)
  end
end
