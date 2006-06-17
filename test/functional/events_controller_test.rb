require File.dirname(__FILE__) + '/../test_helper'
require 'events_controller'

# Re-raise errors caught by the controller.
class EventsController; def rescue_action(e) raise e end; end

class EventsControllerTest < Test::Unit::TestCase
  fixtures :events, :locations, :members

  def setup
    @controller = EventsController.new
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

    assert_not_nil assigns(:events)
  end

  def test_show
    get :show, :id => events(:babyshower).id

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:event)
    assert assigns(:event).valid?
  end

  def test_new
    assert_requires_login { get :new }

    assert_accepts_login(:bob) {
      get :new

      assert_template 'new'
      assert_not_nil assigns(:event)
    }
  end

  def test_create
    assert_requires_login { get :create }

    num_events = Event.count

    assert_accepts_login(:bob) {
      post :create, :event => {
        :location_id => locations(:first).id,
        :name => 'Functional test event',
        :starts_at => Time.now,
        :ends_at => Time.now,
        :agenda => 'Things happen.'
      }

      assert_redirected_to :action => 'list'
    }

    assert_equal num_events + 1, Event.count
  end

  def test_edit
    assert_requires_login { get :edit, :id => events(:babyshower).id }

    assert_accepts_login(:bob) {
      get :edit, :id => events(:babyshower).id

      assert_template 'edit'

      assert_not_nil assigns(:event)
      assert assigns(:event).valid?
    }
  end

  def test_update
    # TODO This causes an error due to a bug
    #assert_requires_login { post :update, :id => events(:babyshower).id }

    assert_accepts_login(:bob) {
      post :update, {
        :id => events(:babyshower).id,
        :trivial => true,
        :event => { :location_id => locations(:first).id }
      }

      assert_redirected_to :action => 'show', :id => events(:babyshower).id
    }
  end

  def test_destroy
    # TODO The access control here redirects differently from the others.
    #assert_requires_login { post :destroy, :id => events(:babyshower).id }

    assert_not_nil Event.find(events(:babyshower).id)

    assert_accepts_login(:bob) {
      post :destroy, :id => events(:babyshower).id

      assert_redirected_to :action => 'list'
    }

    assert_raise(ActiveRecord::RecordNotFound) {
      Event.find(events(:babyshower).id)
    }
  end

  def test_trivial_change
    setup_for_mail_tests

    assert_accepts_login(:bob) {
      post :update, {
        :id => events(:babyshower).id,
        :trivial => true,
        :event => { :location_id => locations(:first).id }
      }

      assert_redirected_to :action => 'show', :id => events(:babyshower).id
    }

    assert ActionMailer::Base.deliveries.empty?
  end

  protected

  def setup_for_mail_tests
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []
  end
end
