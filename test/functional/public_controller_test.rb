require 'test_helper'

class PublicControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
  end

  test "should get chapter" do
    get :chapter
    assert_response :success
  end

end
