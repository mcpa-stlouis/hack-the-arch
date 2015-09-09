require 'test_helper'

class ProblemsControllerTest < ActionController::TestCase
	def setup
		@problem = problems(:example_problem)
		@non_admin = users(:archer)
	end

	test "should redirect index when not logged in" do
    get :index
    assert_not flash.empty?
    assert_redirected_to login_url
  end

	test "should redirect show when not logged in" do
    get :show, id: @problem
    assert_not flash.empty?
    assert_redirected_to login_url
  end

  test "should redirect create when not logged in" do
    post :create, id: @problem, problem: { name: @problem.name, category: @problem.category, description: @problem.description, points: @problem.points }
    assert_not flash.empty?
    assert_redirected_to login_url
  end

  test "should redirect create when not admin" do
    log_in_as(@non_admin)
    post :create, id: @problem, problem: { name: @problem.name, category: @problem.category, description: @problem.description, points: @problem.points }
    assert_not flash.empty?
    assert_redirected_to root_url
  end

  test "should redirect new when not logged in" do
    get :new
    assert_not flash.empty?
    assert_redirected_to login_url
  end

  test "should redirect new when not admin" do
    log_in_as(@non_admin)
    get :new
    assert_not flash.empty?
    assert_redirected_to root_url
  end

	test "should redirect edit when not logged in" do
    get :edit, id: @problem
    assert_not flash.empty?
    assert_redirected_to login_url
  end

	test "should redirect edit when not admin" do
    log_in_as(@non_admin)
    get :edit, id: @problem
    assert_not flash.empty?
    assert_redirected_to root_url
  end

  test "should redirect update when not logged in" do
    patch :update, id: @problem, problem: { name: @problem.name, category: @problem.category, description: @problem.description, points: @problem.points }
    assert_not flash.empty?
    assert_redirected_to login_url
  end

  test "should redirect update when not admin" do
    log_in_as(@non_admin)
    patch :update, id: @problem, problem: { name: @problem.name, category: @problem.category, description: @problem.description, points: @problem.points }
    assert_not flash.empty?
    assert_redirected_to root_url
  end

  test "should redirect destroy when not logged in" do
    delete :destroy, id: @problem, problem: { name: @problem.name, category: @problem.category, description: @problem.description, points: @problem.points }
    assert_not flash.empty?
    assert_redirected_to login_url
  end

  test "should redirect destroy when not admin" do
    log_in_as(@non_admin)
    delete :destroy, id: @problem, problem: { name: @problem.name, category: @problem.category, description: @problem.description, points: @problem.points }
    assert_not flash.empty?
    assert_redirected_to root_url
  end

end
