require 'test_helper'

class SubmissionsTest < ActionDispatch::IntegrationTest
	def setup
		@non_admin = users(:archer)
		@problem = problems(:example_problem)
	end

	test "should add points when correct submission is made" do
		log_in_as(@non_admin)
		get problems_path
		assert flash.empty?

		@score = Team.find(@non_admin.team_id).get_score
		assert_response :success
    post submit_path, submission: { id: @problem.id, 
																	 	value: @problem.solution }
		assert_not_equal @score, Team.find(@non_admin.team_id).get_score
	end

	test "should not add points when incorrect submission is made" do
		log_in_as(@non_admin)
		get problems_path
		assert flash.empty?

		@score = Team.find(@non_admin.team_id).get_score
		assert_response :success
    post submit_path, submission: { id: @problem.id, 
																	 	value: "  " }
		assert_equal @score, Team.find(@non_admin.team_id).get_score
	end

	test "should not work when not logged in" do
    post submit_path, submission: { id: @problem.id, 
																	 	value: "  " }
		assert_not flash.empty?
		assert_redirected_to login_url
	end
		
end
