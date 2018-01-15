require 'test_helper'

class SubmissionsControllerTest < ActionController::TestCase
  def setup
    @admin = users(:example_user)
    @non_admin = users(:archer)
    @problem = problems(:example_problem)
  end

  test "should redirect request when not logged in" do
    post :create, params: {problem_id: @problem.id}
    assert_not flash.empty?
    assert_redirected_to login_url
  end

  test "should redirect index when not logged in" do
    get :index
    assert_not flash.empty?
    assert_redirected_to login_url
  end

  test "should redirect index when not admin" do
    log_in_as(@non_admin)
    get :index
    assert_not flash.empty?
    assert_redirected_to root_url
  end

  test "should get index when admin" do
    log_in_as(@admin)
    get :index
    assert_response :success
  end

end
