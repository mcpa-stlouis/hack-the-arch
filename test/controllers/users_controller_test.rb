require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  def setup
    @admin = users(:example_user)
    @archer = users(:archer)
    @malory = users(:malory)
    @view_other_profiles = settings(:view_other_profiles)
    @activation_emails = settings(:setting_send_activation_emails)
    @admin_account_auth = settings(:admin_account_auth)
  end

  def turn_off_other_profile_view
    log_in_as(@admin)
    @view_other_profiles.update_attribute(:value, '0')
    log_out
  end

  def turn_on_payment_required
    log_in_as(@admin)
    @require_payment.update_attribute(:value, '1')
    log_out
  end

  def turn_on_admin_auth
    log_in_as(@admin)
    @admin_account_auth.update_attribute(:value, '1')
    log_out
  end

  def turn_off_activation_emails
    log_in_as(@admin)
    @activation_emails.update_attribute(:value, '0')
    log_out
  end

  def deactivate_account(user)
    log_in_as(@admin)
    @user = User.find(user.id)
    @user.update_attribute(:activated, false)
    log_out
  end

  def deauthorize_account(user)
    log_in_as(@admin)
    @user = User.find(user.id)
    @user.update_attribute(:authorized, false)
    log_out
  end

  test "should redirect index if not logged in" do
    get :index
    assert_not flash.empty?
    assert_redirected_to login_url
  end

  test "should get index if admin" do
    log_in_as(@admin)
    get :index
    assert_response :success
  end

  test "should redirect index if not admin" do
    log_in_as(@archer)
    get :index
    assert_not flash.empty?
    assert_redirected_to root_url
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should redirect edit when not logged in" do
    get :edit, params: {id: @archer}
    assert_not flash.empty?
    assert_redirected_to login_url
  end

  test "should redirect update when not logged in" do
    patch :update, params: {id: @archer, user: { fname: @archer.fname, lname: @archer.lname, email: @archer.email }}
    assert_not flash.empty?
    assert_redirected_to login_url
  end

  test "should redirect edit when logged in as wrong user" do
    log_in_as(@archer)
    get :edit, params: {id: @admin}
    assert_not flash.empty?
    assert_redirected_to root_url
  end

  test "should redirect update when logged in as wrong user" do
    log_in_as(@archer)
    patch :update, params: {id: @admin, user: { fname: @admin.fname, lname: @admin.lname, email: @admin.email }}
    assert_not flash.empty?
    assert_redirected_to root_url
  end

  test "should redirect destroy when logged in as non-admin user" do
    log_in_as(@archer)
    delete :destroy, params: {id: @malory}
    assert_not flash.empty?
    assert_redirected_to root_url
  end

  test "should show own user profile when activated" do
    log_in_as(@archer)
    get :show, params: {id: @archer}
    assert_response :success
  end

  test "should redirect other profile when not activated" do
    deactivate_account(@archer)
    log_in_as(@admin)
    get :show, params: {id: @archer}
    assert_not flash.empty?
    assert_redirected_to root_url
  end

  test "should redirect own profile when not activated" do
    deactivate_account(@archer)
    log_in_as(@archer)
    get :show, params: {id: @archer}
    assert_not flash.empty?
    assert_redirected_to root_url
  end

  test "should redirect show other activated user after disabled setting" do
    turn_off_other_profile_view
    log_in_as(@archer)
    get :show, params: {id: @admin}
    assert_not flash.empty?
    assert_redirected_to root_url
  end

  test "should redirect user stats when not logged in" do
    get :get_stats, params: {id: @archer}
    assert_not flash.empty?
    assert_redirected_to login_url
  end

  test "should get user stats when logged in" do
    log_in_as(@archer)
    get :get_stats, params: {id: @archer}
    assert_response :success
  end

  test "should redirect when requesting user stats of non-existent user" do
    log_in_as(@archer)
    get :get_stats, params: {id: 9}
    assert_not flash.empty?
    assert_redirected_to root_url
  end

  test "should redirect show if user is not authorized" do
    turn_on_admin_auth
    log_in_as(@archer)
    @archer.update_attribute(:authorized, false)

    get :show, params: {id: @archer}
    assert_redirected_to root_url
  end

  test "should redirect attempt to destroy user by non-logged in user" do
    post :destroy, params: {id: @malory}
    assert_redirected_to login_url
  end

  test "should redirect destroy if not admin" do
    log_in_as(@archer)
    post :destroy, params: {id: @malory}
    assert_redirected_to root_url
  end

  test "should allow destroy if admin" do
    @num_users = User.all.count 
    log_in_as(@admin)
    post :destroy, params: {id: @malory}
    assert_redirected_to users_url
    assert_not @num_users == User.all.count
  end

  test "should redirect attempt to activate user by non-logged in user" do
    post :activate, params: {id: @malory}
    assert_redirected_to login_url
  end

  test "should redirect activate if not admin" do
    log_in_as(@archer)
    post :activate, params: {id: @malory}
    assert_redirected_to root_url
  end

  test "should redirect activate if user already activated" do
    log_in_as(@admin)
    post :activate, params: {id: @malory}
    assert_redirected_to users_url
  end

  test "should allow activate if not already activated and admin" do
    deactivate_account(@malory)
    log_in_as(@admin)
    post :activate, params: {id: @malory}
    assert_redirected_to users_url
    assert @malory.activated?
  end

  test "should redirect attempt to authorize user by non-logged in user" do
    post :authorize, params: {id: @malory}
    assert_redirected_to login_url
  end

  test "should redirect authorize if not admin" do
    log_in_as(@archer)
    post :authorize, params: {id: @malory}
    assert_redirected_to root_url
  end

  test "should redirect authorize if user already authorized" do
    log_in_as(@admin)
    post :authorize, params: {id: @malory}
    assert_redirected_to users_url
  end

  test "should allow authorize if not already authorized and admin" do
    deauthorize_account(@malory)
    log_in_as(@admin)
    post :authorize, params: {id: @malory}
    assert_redirected_to users_url
    assert @malory.authorized?
  end

  test "should redirect new when registration isn't active" do
    settings(:registration_active).update_attribute(:value, '0')
    get :new
    assert_redirected_to root_url
  end

  test "should redirect charge when payment isn't required" do
    post :charge, params: {id: @archer}
    assert_redirected_to root_url
  end

  test "should redirect checkout when payment isn't required" do
    get :checkout, params: {id: @archer}
    assert_redirected_to root_url
  end

end
