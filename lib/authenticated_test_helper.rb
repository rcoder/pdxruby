# $Id$

module AuthenticatedTestHelper
  # Sets the current member in the session from the member fixtures.
  def login_as(member)
    @request.session[:member] = members(member)
  end

  # Assert the block redirects to the login
  #
  #   assert_requires_login(:bob) { get :edit, :id => 1 }
  #
  def assert_requires_login(member = nil, &block)
    login_as(member) if member
    block.call
    assert_redirected_to :controller => 'members', :action => 'login'
  end

  # Assert the block accepts the login
  # 
  #   assert_accepts_login(:bob) { get :edit, :id => 1 }
  #
  # Accepts anonymous logins:
  #
  #   assert_accepts_login { get :list }
  #
  def assert_accepts_login(member = nil, &block)
    login_as(member) if member
    block.call
  end
end
