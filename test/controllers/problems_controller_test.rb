require 'test_helper'

class ProblemsControllerTest < ActionController::TestCase
	def setup
		@problem = problems(:example_problem)
		@hint = hints(:example_hint_1)
		@non_admin = users(:archer)
		@admin = users(:example_user)
	end

	test "should redirect index when not logged in" do
    get :index
    assert_not flash.empty?
    assert_redirected_to login_url
  end

	test "should get index when logged in" do
		log_in_as(@non_admin)
		get :index
		assert_response :success
	end

	test "should redirect show to problems_url" do
		log_in_as(@non_admin)
		get :show, id: @problem.id
		assert_redirected_to problems_url + "?problem_id=#{@problem.id}#heading_#{@problem.id - 1}"
	end

  test "should redirect create when not logged in" do
    post :create, problem: { name: @problem.name, 
														 description: @problem.description,
														 category: @problem.category,
														 points: @problem.points,
														 solution: @problem.solution,
														 correct_message: @problem.correct_message,
														 false_message: @problem.false_message,
														 visible: @problem.visible}
    assert_not flash.empty?
    assert_redirected_to login_url
  end

  test "should redirect create when not admin" do
    log_in_as(@non_admin)
    post :create, problem: { name: @problem.name, 
														 description: @problem.description,
														 category: @problem.category,
														 points: @problem.points,
														 solution: @problem.solution,
														 correct_message: @problem.correct_message,
														 false_message: @problem.false_message,
														 visible: @problem.visible}
    assert_not flash.empty?
    assert_redirected_to root_url
  end

	test "should allow create when admin" do
    log_in_as(@admin)
    post :create, problem: { name: @problem.name, 
														 description: @problem.description,
														 category: @problem.category,
														 points: @problem.points,
														 solution: @problem.solution,
														 correct_message: @problem.correct_message,
														 false_message: @problem.false_message,
														 visible: @problem.visible,
														 solution_case_sensitive: @problem.solution_case_sensitive}
    assert_redirected_to problems_url
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

  test "should get new when admin" do
    log_in_as(@admin)
    get :new
    assert_response :success
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

	test "should get edit when admin" do
		log_in_as(@admin)
		get :edit, id: @problem
		assert_response :success
	end

  test "should redirect update when not logged in" do
    patch :update, id: @problem, problem: { name: @problem.name, 
														 								description: @problem.description,
														 								category: @problem.category,
														 								points: @problem.points,
														 								solution: @problem.solution,
														 								correct_message: @problem.correct_message,
														 								false_message: @problem.false_message,
														 								visible: @problem.visible}
    assert_not flash.empty?
    assert_redirected_to login_url
  end

  test "should redirect update when not admin" do
    log_in_as(@non_admin)
    patch :update, id: @problem, problem: { name: @problem.name, 
														 								description: @problem.description,
														 								category: @problem.category,
														 								points: @problem.points,
														 								solution: @problem.solution,
														 								correct_message: @problem.correct_message,
														 								false_message: @problem.false_message,
														 								visible: @problem.visible}
    assert_not flash.empty?
    assert_redirected_to root_url
  end

  test "should allow update when admin" do
    log_in_as(@admin)
    patch :update, id: @problem, problem: { name: @problem.name, 
														 								description: @problem.description,
														 								category: @problem.category,
														 								points: @problem.points,
														 								solution: @problem.solution,
														 								correct_message: @problem.correct_message,
														 								false_message: @problem.false_message,
														 								visible: @problem.visible}
    assert_redirected_to @problem
  end

  test "should redirect destroy when not logged in" do
    delete :destroy, id: @problem
    assert_not flash.empty?
    assert_redirected_to login_url
  end

  test "should redirect destroy when not admin" do
    log_in_as(@non_admin)
    delete :destroy, id: @problem
    assert_not flash.empty?
    assert_redirected_to root_url
  end

  test "should allow destroy when admin" do
    log_in_as(@admin)
    delete :destroy, id: @problem
    assert_redirected_to problems_url
  end

end
