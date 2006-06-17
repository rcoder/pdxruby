require File.dirname(__FILE__) + '/../test_helper'
require 'participants_controller'

# Re-raise errors caught by the controller.
class ParticipantsController; def rescue_action(e) raise e end; end

class ParticipantsControllerTest < Test::Unit::TestCase
  fixtures :events, :members, :participants

  def setup
    @controller = ParticipantsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_index
    get :index

    assert_template 'list'
  end

  def test_list
    get :list

    assert_template 'list'

    assert_not_nil assigns(:participants)
  end

  def test_show
    get :show, :id => 1

    assert_template 'show'

    assert_not_nil assigns(:participant)
    assert assigns(:participant).valid?
  end

  def test_new
    get :new, :event => events(:babyshower).id

    assert_template 'new'

    assert_not_nil assigns(:participant)
  end

  def test_create
    # TODO Currently this action will display a form even without a login
    #assert_requires_login { post :create }

    num_participants = Participant.count

    assert_accepts_login(:bob) {
      post :create, {
        :event => { :id => events(:babyshower).id },
        :participant => { :attending => 'maybe' }
      }

      assert_redirected_to(:controller => 'events',
                           :action => 'show',
                           :id => events(:babyshower).id)
    }

    assert_equal num_participants + 1, Participant.count
  end

  def test_edit
    # TODO This causes an error due to a bug
    #assert_requires_login { get :edit, :id => 1 }

    assert_accepts_login(:bob) {
      get :edit, :id => 1

      assert_template 'edit'
      assert_not_nil assigns(:participant)
      assert assigns(:participant).valid?
    }
  end

  def test_update
    # TODO This causes an error due to a bug
    #assert_requires_login { post :update, :id => 1 }

    assert_accepts_login(:bob) {
      post :update, :id => 1
      assert_redirected_to :action => 'show', :id => 1
    }
  end

  def test_destroy
    assert_not_nil Participant.find(1)

    post :destroy, :id => 1
    assert_redirected_to :action => 'list'

    assert_raise(ActiveRecord::RecordNotFound) {
      Participant.find(1)
    }
  end
end
