require 'test_helper'

class ScoreboardTest < ActionDispatch::IntegrationTest
	def setup
		@admin = users(:example_user)
		@non_admin = users(:archer)
		@start_time = settings(:setting_start_time_active)
		@scoreboard_on = settings(:setting_scoreboard_on)
	end

	def make_comp_inactive
		log_in_as(@admin)
		@start_time.value = (DateTime.current + 5.minutes).strftime("%m/%d/%Y %I:%M %p")
		@start_time.save
		log_out
	end

	def turn_scoreboard_off
		log_in_as(@admin)
		@scoreboard_on.value = '0'
		@scoreboard_on.save
		log_out
	end

	test "should get score progressions" do
		get '/teams/get_score_data'
    assert_response :success
	end

	test "should show scoreboard when scoreboard is off and admin" do
		turn_scoreboard_off
		log_in_as(@admin)
		get '/scoreboard'
    assert_select 'div#scoreboard_graph', count: 1
	end

	test "should hide scoreboard when scoreboard is off and not admin" do
		turn_scoreboard_off
		get '/scoreboard'
    assert_select 'div#scoreboard_graph', count: 0
	end

	test "should not redirect index when competition hasn't started and admin" do
		make_comp_inactive
		log_in_as(@admin)
		get '/scoreboard'
		assert flash.empty?
		assert_response :success
	end

	test "should redirect index when competition hasn't started" do
		make_comp_inactive
		log_in_as(@non_admin)
		get '/scoreboard'
		assert_not flash.empty?
		assert_redirected_to root_url
	end

end
