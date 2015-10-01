require 'test_helper'

class HintsControllerTest < ActionController::TestCase
	def setup
		@hint = hints(:example_hint_1)
		@non_admin = users(:archer)
		@admin = users(:example_user)
		@problem = problems(:example_problem)
	end

	test "should redirect new when not logged in" do
    get :new
    assert_not flash.empty?
    assert_redirected_to login_url
  end

	test "should redirect new when not logged in as admin" do
		log_in_as(@non_admin)
    get :new
    assert_not flash.empty?
    assert_redirected_to root_url
  end

	test "should get new when logged in as admin" do
		log_in_as(@admin)
    post :new, problem_id: @problem.id
    assert_response :success
  end

	test "should redirect create when not logged in" do
    post :create, hint: { priority: @hint.priority, hint: @hint.hint, points: @hint.points }
    assert_not flash.empty?
    assert_redirected_to login_url
  end

	test "should redirect create when not logged in as admin" do
		log_in_as(@non_admin)
    post :create, hint: { priority: @hint.priority, hint: @hint.hint, points: @hint.points }
    assert_not flash.empty?
    assert_redirected_to root_url
  end

	test "should allow create when logged in as admin" do
		log_in_as(@admin)
    post :create, hint: { priority: @hint.priority, hint: @hint.hint, points: @hint.points, problem_id: @problem.id }
    assert_redirected_to @problem
  end


	test "should redirect edit when not logged in" do
    get :edit, id: @hint.id
    assert_not flash.empty?
    assert_redirected_to login_url
  end

	test "should redirect edit when not logged in as admin" do
		log_in_as(@non_admin)
    get :edit, id: @hint.id
    assert_not flash.empty?
    assert_redirected_to root_url
  end

	test "should redirect update when not logged in" do
    patch :update, id: @hint.id, hint: { priority: @hint.priority, hint: @hint.hint, points: @hint.points }
    assert_not flash.empty?
    assert_redirected_to login_url
  end

	test "should redirect update when not logged in as admin" do
		log_in_as(@non_admin)
    patch :update, id: @hint.id, hint: { priority: @hint.priority, hint: @hint.hint, points: @hint.points }
    assert_not flash.empty?
    assert_redirected_to root_url
  end

end
