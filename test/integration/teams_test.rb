require 'test_helper'

class TeamsTest < ActionDispatch::IntegrationTest
	def setup
		@admin = users(:example_user)
		@non_admin = users(:archer)
		@team = teams(:example_team)
	end

	test "should create a team and add the creating user to it" do

		log_in_as(@admin)
    delete team_path @team
		assert_redirected_to teams_url

		log_in_as(@non_admin)
    post teams_path, team: { name: @team.name,
                             bracket_id: @team.bracket_id,
                             passphrase: @team.passphrase }
		assert_response :success
		get team_path Team.last
    assert_select "a[href=?]", "/users/#{@non_admin.id}", count: 0
	end

end
