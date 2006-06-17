require File.dirname(__FILE__) + '/../test_helper'
require 'locations_controller'

# Re-raise errors caught by the controller.
class LocationsController; def rescue_action(e) raise e end; end

class LocationsControllerTest < Test::Unit::TestCase
  fixtures :locations, :members

  def setup
    @controller = LocationsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_index
    get :index
    assert_response :success
    assert_template 'list'
  end

  def test_list
    get :list

    assert_response :success
    assert_template 'list'

    assert_not_nil assigns(:locations)
  end

  def test_show
    get :show, :id => locations(:first).id

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:location)
    assert assigns(:location).valid?
  end

  def test_new
    assert_requires_login { get :new }

    assert_accepts_login(:bob) {
      get :new

      assert_template 'new'
      assert_not_nil assigns(:location)
    }
  end

  def test_create
    assert_requires_login { post :create }

    num_locations = Location.count

    assert_accepts_login(:bob) {
      post :create, :location => {
        :name => 'Functional test',
        :address => 'That one place'
      }

      assert_redirected_to :action => 'list'
    }

    assert_equal num_locations + 1, Location.count
  end

  def test_edit
    assert_requires_login { get :edit, :id => locations(:first).id }

    assert_accepts_login(:bob) {
      get :edit, :id => locations(:first).id

      assert_template 'edit'
      assert_not_nil assigns(:location)
      assert assigns(:location).valid?
    }
  end

  def test_update
    post :update, :id => locations(:first).id
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => locations(:first).id
  end

  def test_destroy
    assert_requires_login { post :destroy, :id => locations(:first).id }

    assert_not_nil Location.find(locations(:first).id)

    assert_accepts_login(:bob) {
      post :destroy, :id => locations(:first).id
      assert_redirected_to :action => 'list'
    }

    assert_raise(ActiveRecord::RecordNotFound) {
      Location.find(locations(:first).id)
    }
  end
end
