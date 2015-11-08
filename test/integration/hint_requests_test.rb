require 'test_helper'

class HintRequestsTest < ActionDispatch::IntegrationTest
	def setup
		@admin = users(:example_user)
		@non_admin = users(:archer)
		@problem = problems(:example_problem_2) #Has hint
		# Defaults to false
		@subtract_points_for_hints = settings(:setting_subtract_hint_points_before_solve)
	end

	def sub_points_for_hints
		log_in_as(@admin)
		@subtract_points_for_hints.value = true
		@subtract_points_for_hints.save
		log_out
	end

	test "should not subtract points for hint request" do
		log_in_as(@non_admin)
		get problems_path
		assert flash.empty?

		@score = Team.find(@non_admin.team_id).get_score
		@hints = Team.find(@non_admin.team_id).get_hints_requested(@problem.id).size
		assert_response :success
    post request_hint_path, problem_id: @problem.id
		assert_equal @score, Team.find(@non_admin.team_id).get_score
		assert_not_equal @hints, Team.find(@non_admin.team_id).get_hints_requested(@problem.id).size
	end

	test "should subtract points for hint request" do
		sub_points_for_hints
		log_in_as(@non_admin)
		get problems_path
		assert flash.empty?

		@score = Team.find(@non_admin.team_id).get_score
		assert_response :success
    post request_hint_path, problem_id: @problem.id
		assert_not_equal @score, Team.find(@non_admin.team_id).get_score
	end

end
