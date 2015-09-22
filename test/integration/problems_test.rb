require 'test_helper'

class ProblemsTest < ActionDispatch::IntegrationTest
	def setup
		@admin = users(:example_user)
		@non_admin = users(:archer)
		@start_time = settings(:setting_start_time_active)
		@problem = problems(:example_problem)
	end

	def make_comp_inactive
		log_in_as(@admin)
		@start_time.value = Time.zone.now + 5.minutes
		@start_time.save
		log_out
	end

	test "should not redirect index when competition hasn't started and admin" do
		make_comp_inactive
		log_in_as(@admin)
		get '/problems'
		assert flash.empty?
		assert_response :success
	end

	test "should redirect index when competition hasn't started" do
		make_comp_inactive
		log_in_as(@non_admin)
		get '/problems'
		assert_not flash.empty?
		assert_redirected_to root_url
	end

	test "should redirect show when competition hasn't started" do
		make_comp_inactive
		log_in_as(@non_admin)
		get "/problems/#{@problem.id}"
		assert_not flash.empty?
		assert_redirected_to root_url
	end

end
