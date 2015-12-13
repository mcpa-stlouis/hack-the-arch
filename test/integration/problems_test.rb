require 'test_helper'

class ProblemsTest < ActionDispatch::IntegrationTest
	def setup
		@admin = users(:example_user)
		@non_admin = users(:archer)
		@start_time = settings(:setting_start_time_active)
		@problem = problems(:example_problem)
		@hint = hints(:example_hint_1)
	end

	def make_comp_inactive
		log_in_as(@admin)
		@start_time.value = (DateTime.current + 5.minutes).strftime("%m/%d/%Y %I:%M %p")
		@start_time.save
		log_out
	end

	test "should not redirect index when not logged in" do
		get problems_path
		assert_not flash.empty?
		assert_redirected_to login_url
	end

	test "should not redirect index when competition hasn't started and admin" do
		make_comp_inactive
		log_in_as(@admin)
		get problems_path
		assert flash.empty?
		assert_response :success
	end

	test "should redirect index when competition hasn't started" do
		make_comp_inactive
		log_in_as(@non_admin)
		get problems_path
		assert_not flash.empty?
		assert_redirected_to root_url
	end

	test "should redirect show when competition hasn't started" do
		make_comp_inactive
		log_in_as(@non_admin)
		get problem_path(@problem)
		assert_not flash.empty?
		assert_redirected_to root_url
	end

	test "should create, update, add hint, and delete problem when admin" do
		log_in_as(@admin)

    delete problem_path @problem
		assert_redirected_to problems_url
    assert_select "a[href=?]", "#main_problem_#{@problem.id}", count: 0

    post problems_path, problem: { name: @problem.name, 
																	 description: @problem.description,
																	 category: @problem.category,
																	 points: @problem.points,
																	 solution: @problem.solution,
																	 correct_message: @problem.correct_message,
																	 false_message: @problem.false_message,
																	 visible: @problem.visible,
																	 solution_case_sensitive: @problem.solution_case_sensitive}
		assert_redirected_to problems_url
		get problems_path
		@problem = Problem.last
    assert_select "a[href=?]", "#main_problem_#{@problem.id}", count: 1

		# Add existing hint
		get problems_path
		post '/problems/add_hint', problem_id: @problem.id, hint_id: @hint.id
		assert_response :success
		get problem_path(@problem)
		follow_redirect!
    assert_select "h5[id=prob_#{@problem.id}_hint_row_#{@hint.id}]", count: 1

		# Create new hint and add it 
    post_via_redirect hints_path, hint: { priority: @hint.priority, 
														 							hint: @hint.hint,
														 							points: @hint.points,
														 							problem_id: @problem.id}
		assert_response :success
		get problem_path(@problem)
		follow_redirect!

    assert_select "h5[id=prob_#{@problem.id}_hint_row_#{Hint.last.id}]", count: 1

		# Remove a hint
		delete remove_hint_path(problem_id: @problem.id, hint_id: Hint.last.id)
		assert_redirected_to @problem
		follow_redirect!
    assert_select "h5[id=prob_#{@problem.id}_hint_row_#{Hint.last.id}]", count: 0

		# Remove the problem
    delete problem_path @problem
		assert_redirected_to problems_url
		follow_redirect!
    assert_select "a[href=?]", "#main_problem_#{@problem.id}", count: 0
	end

end
