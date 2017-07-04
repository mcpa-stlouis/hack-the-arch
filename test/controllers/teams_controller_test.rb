require 'test_helper'

class TeamsControllerTest < ActionController::TestCase
  def setup
    @user = users(:archer)
    @team = teams(:example_team)
    @opponent = users(:malory)
    @opponent_team = teams(:opponent_team)
    @admins = teams(:admins)
  end

  test "should get index" do
    get :index
    assert_response :success
  end

  test "should redirect non-admins showing admin team" do
    log_in_as(@user)
    get :show, params: {id: @admins.id}
    assert_redirected_to root_url
  end

  test "should redirect non-logged in users on get new" do
    get :new
    assert_redirected_to login_url
  end

  test "should not update team for logged in user without invalid params" do
    log_in_as(@user)
    @short_passphrase = "l33t"
    patch :update, params: {id: @user.team.id, team: { name: @user.team.name,
                                                       passphrase: @short_passphrase, 
                                                       bracket_id: @user.team.bracket_id }}
    assert_template :edit
  end

  test "should update team for logged in user" do
    log_in_as(@user)
    @new_team_name = "L33t Hax0rs"
    patch :update, params: {id: @team.id, team: { name: @new_team_name,
                                                  passphrase: @team.passphrase, 
                                                  bracket_id: @team.bracket_id }}
    assert_redirected_to @team
  end

  test "should redirect on create with bad parameters" do
    log_in_as(@user)
    post :create, params: {team: { name: "Testing Team",
                                   passphrase: "pass",
                                   bracket_id: @team.bracket_id }}
    assert_template :new
  end

  test "should flash danger when attempting to remove member from other team" do
    log_in_as(@user)
    post :remove_member, params: {team_id: @opponent_team.id, 
                                  user_id: @opponent.id}
    assert @opponent.team == @opponent_team
  end

  test "should redirect on create with non-logged in user and bad parameters" do
    post :create, params: {team: { name: "Testing Team",
                                   passphrase: "pass",
                                   bracket_id: @team.bracket_id }}
    assert_redirected_to login_url
  end

  test "should get new page when user logged in" do
    log_in_as(@user)
    get :new
    assert_response :success
  end

  test "should get show when logged in" do
    log_in_as(@user)
    get :show, params: {id: @user.team.id}
    assert_response :success
  end

  test "should redirect show when not logged in" do
    get :show, params: {id: @team.id}
    assert_not flash.empty?
    assert_redirected_to login_url
  end

  test "should redirect edit when not logged in" do
    get :edit, params: {id: @team.id}
    assert_not flash.empty?
    assert_redirected_to login_url
  end

  test "should redirect edit when not logged in as member of team" do
    log_in_as(@user)
    get :edit, params: {id: @admins.id}
    assert_not flash.empty?
    assert_redirected_to root_url
  end

  test "should redirect update when not logged in as member of team" do
    log_in_as(@user)
    patch :update, params: {id: @admins.id, team: { name: @admins.name, passphrase: @admins.passphrase, bracket_id: @admins.bracket_id }}
    assert_not flash.empty?
    assert_redirected_to root_url
  end

  test "should redirect destroy when not logged in as member of team" do
    log_in_as(@user)
    delete :destroy, params: {id: @admins.id}
    assert_not flash.empty?
    assert_redirected_to root_url
  end

  test "should not allow user to add another user to his/her team" do
    log_in_as(@user)
    post :join, params: {user_id: @opponent.id, team_id: @team.id}
    assert @opponent.team == @opponent_team
  end

  test "should not allow user to join his/her team twice" do
    log_in_as(@user)
    @team_size = @team.users.size
    post :join, params: {user_id: @user.id, team_id: @team.id}
    assert @team_size == @team.users.size
  end

  test "should not allow user to join team with incorrect passphrase" do
    log_in_as(@user)
    @opp_team_size = @opponent_team.users.size
    post :remove_member, params: {team_id: @team.id, user_id: @user.id}
    post :join, params: {user_id: @user.id, 
                         team_id: @opponent_team.id, 
                         passphrase: "asdf"}
    assert_not @team.users.include? @user
    assert @opp_team_size == @opponent_team.users.size

    # Join correct team again
    post :join, params: {user_id: @user.id, 
                         team_id: @team.id, 
                         passphrase: "password"}
    assert @team.users.include? @user
  end

  test "should redirect trying to join admins team if not admin" do
    log_in_as(@user)
    post :remove_member, params: {team_id: @team.id, user_id: @user.id}
    post :join, params: {user_id: @user.id, 
                         team_id: @admins.id, 
                         passphrase: "password"}
    assert_redirected_to root_url

    post :join, params: {user_id: @user.id, 
                         team_id: @team.id, 
                         passphrase: "password"}
  end
    
end
