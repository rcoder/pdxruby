require File.dirname(__FILE__) + '/../test_helper'
require 'members_controller'

# Re-raise errors caught by the controller.
class MembersController; def rescue_action(e) raise e end; end

class MembersControllerTest < Test::Unit::TestCase
  fixtures :members

  def setup
    @controller = MembersController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_index
    get :index
    assert_redirected_to :action => 'login'
  end

  def test_list
    assert_requires_login { get :list }

    assert_accepts_login(:bob) {
      get :list

      assert_template 'list'
      assert_not_nil assigns(:members)
    }
  end

  def test_show
    assert_requires_login { get :show, :id => 1 }

    assert_accepts_login(:bob) {
      get :show, :id => 1

      assert_template 'show'
      assert_not_nil assigns(:member)
    }
  end

  def test_edit
    assert_requires_login { get :edit, :id => 1 }

    assert_accepts_login(:bob) {
      get :edit, :id => 1

      assert_template 'edit'
      assert_not_nil assigns(:member)
    }
  end

  def test_update
    assert_requires_login { post :update, :id => members(:bob).id }

    changed_member = members(:bob).dup
    changed_member.name = 'Bob Jr.'

    assert_accepts_login(:bob) {
      post :update, {
        :id => members(:bob).id,
        :member => changed_member.attributes,
        :password => 'abc',
        :verify_password => 'abc'
      }

      assert_equal "Member was successfully updated.", flash[:notice]
      assert_redirected_to :action => 'show'
    }
  end

  def test_anyone_can_register_to_be_a_member
    post :create, {
      :member => {
        :name => 'Anyone',
        :email => 'anyone@anywhere.com',
        :feed_url => 'http://foo/bar.xml',
        :about => 'Something about me.'
      },
      :password => 'abc',
      :verify_password => 'abc'
    }

    assert_redirected_to :action => 'show'
    assert_not_nil Member.find_by_email('anyone@anywhere.com')
  end

  def test_member_cannot_register_again
    post :create, {
      :member => members(:bob).attributes,
      :password => 'abc',
      :verify_password => 'abc'
    }

    # FIXME: A bit of a hack, but it's hard to get to the "errors" array from
    # the functional tests.  That's actually where the details of the error
    # would be.
    assert_equal("Sorry, but the member couldn't be created for some reason.",
                 flash[:notice])
  end

  def test_invalid_login_with_unregistered_member
    post :login, :member => {
      :email => 'bad@bad', :password => 'bad'
    }

    assert_template 'members/login'
    assert_equal "That member doesn't exist.", flash[:notice]
    assert !assigns(:member)
  end

  def test_invalid_login_with_wrong_password
    post :login, :member => {
      :email => members(:bob).email, :password => 'bad'
    }

    assert_template 'members/login'
    assert_equal "Wrong password.", flash[:notice]
    assert !assigns(:member)
  end

  def test_logout
    get :logout

    assert_redirected_to :action => 'login'
  end
end
