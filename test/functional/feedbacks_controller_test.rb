require File.dirname(__FILE__) + '/../test_helper'
require 'feedbacks_controller'

# Re-raise errors caught by the controller.
class FeedbacksController; def rescue_action(e) raise e end; end

class FeedbacksControllerTest < Test::Unit::TestCase
  fixtures :feedbacks, :members, :participants

  def setup
    @controller = FeedbacksController.new
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

    assert_not_nil assigns(:feedbacks)
  end

  def test_show
    get :show, :id => 1

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:feedback)
    assert assigns(:feedback).valid?
  end

  def test_new
    # TODO This causes an error due to a bug
    #assert_requires_login { get :new }

    assert_accepts_login(:bob) {
      get :new

      assert_template 'new'
      assert_not_nil assigns(:feedback)
    }
  end

  def test_create
    # TODO This causes an error due to a bug
    #assert_requires_login { post :create }

    num_feedbacks = Feedback.count

    assert_accepts_login(:bob) {
      post :create, :participant => { :id => participants(:first).id }
      assert_redirected_to(:controller => 'events',
                           :action => 'show',
                           :id => participants(:first).event.id)
    }

    assert_equal num_feedbacks + 1, Feedback.count
  end

  def test_edit
    get :edit, :id => 1

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:feedback)
    assert assigns(:feedback).valid?
  end

  def test_update
    post :update, :id => 1
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => 1
  end

  def test_destroy
    assert_not_nil Feedback.find(1)

    post :destroy, :id => 1
    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_raise(ActiveRecord::RecordNotFound) {
      Feedback.find(1)
    }
  end
end
