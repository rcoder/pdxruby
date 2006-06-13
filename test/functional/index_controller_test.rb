require File.dirname(__FILE__) + '/../test_helper'
require 'index_controller'

# Re-raise errors caught by the controller.
class IndexController; def rescue_action(e) raise e end; end

class IndexControllerTest < Test::Unit::TestCase
  def setup
    @controller = IndexController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_index
    assert_routing '', { :controller => 'index', :action => 'index' }

    get :index
    assert_template 'index'
  end
end
