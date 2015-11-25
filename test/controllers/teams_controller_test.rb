require 'test_helper'

class TeamsControllerTest < ActionController::TestCase
	def setup
		@user = users(:archer)
		@team = teams(:example_team)
		@admins = teams(:admins)
	end

	test "should get index" do
    get :index
    assert_response :success
  end

	test "should get show when logged in" do
		log_in_as(@user)
    get :show, id: @user.team.id
    assert_response :success
  end

	test "should redirect show when not logged in" do
    get :show, id: @team.id
    assert_not flash.empty?
    assert_redirected_to login_url
  end

	test "should redirect edit when not logged in" do
    get :edit, id: @team.id
    assert_not flash.empty?
    assert_redirected_to login_url
  end

	test "should redirect edit when not logged in as member of team" do
		log_in_as(@user)
    get :edit, id: @admins.id
    assert_not flash.empty?
    assert_redirected_to root_url
  end

	test "should redirect update when not logged in as member of team" do
		log_in_as(@user)
    patch :update, id: @admins.id, team: { name: @admins.name, passphrase: @admins.passphrase, bracket_id: @admins.bracket_id }
    assert_not flash.empty?
    assert_redirected_to root_url
  end

	test "should redirect destroy when not logged in as member of team" do
		log_in_as(@user)
    delete :destroy, id: @admins.id
    assert_not flash.empty?
    assert_redirected_to root_url
  end


end
