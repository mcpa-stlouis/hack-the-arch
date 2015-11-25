require 'test_helper'

class TeamsTest < ActionDispatch::IntegrationTest
	def setup
		@admin = users(:example_user)
		@non_admin = users(:archer)
		@team = teams(:example_team)
		@bracket = brackets(:example_bracket)
	end

	test "should delete a team" do

		log_in_as(@admin)
    post remove_member_path, user_id: @non_admin.id, team_id: @team.id
		get teams_path
    assert_select "a[href=?]", "/teams/#{@team.id}", minimum: 1
    delete team_path @team
		assert_redirected_to teams_url
    assert_select "a[href=?]", "/teams/#{@team.id}", count: 0
		log_out

	end

	test "should create a team and add creating member to it" do

		log_in_as(@non_admin)
    post remove_member_path, user_id: @non_admin.id, team_id: @team.id

    post teams_path, team: { name: "Testing Team",
														 passphrase: "password",
														 bracket_id: @bracket.id }
		assert_not flash.empty?
		@new_team = Team.find_by(name: "Testing Team")
		assert_redirected_to @new_team
		assert_equal @new_team.users.last.id, @non_admin.id
		
	end

	test "should leave a team" do

		log_in_as(@non_admin)
    post remove_member_path, user_id: @non_admin.id, team_id: @team.id
		assert_redirected_to @team
    assert_select "a[href=?]", "/users/#{@non_admin.id}", count: 0

	end

end
