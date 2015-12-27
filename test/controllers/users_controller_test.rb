require 'test_helper'

class UsersControllerTest < ActionController::TestCase
	def setup
		@admin = users(:example_user)
		@archer = users(:archer)
		@malory = users(:malory)
		@view_other_profiles = settings(:view_other_profiles)
	end

	def turn_off_other_profile_view
		log_in_as(@admin)
		@view_other_profiles.value = '0'
		@view_other_profiles.save
		log_out
	end

	def deactivate_account(user)
		log_in_as(@admin)
		@user = User.find(user.id)
    @user.update_attribute(:activated, false)
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
    get :edit, id: @archer
    assert_not flash.empty?
    assert_redirected_to login_url
  end

  test "should redirect update when not logged in" do
    patch :update, id: @archer, user: { fname: @archer.fname, lname: @archer.lname, email: @archer.email }
    assert_not flash.empty?
    assert_redirected_to login_url
  end

	test "should redirect edit when logged in as wrong user" do
    log_in_as(@archer)
    get :edit, id: @admin
    assert_not flash.empty?
    assert_redirected_to root_url
  end

  test "should redirect update when logged in as wrong user" do
    log_in_as(@archer)
    patch :update, id: @admin, user: { fname: @admin.fname, lname: @admin.lname, email: @admin.email }
    assert_not flash.empty?
    assert_redirected_to root_url
  end

  test "should redirect destroy when logged in as non-admin user" do
    log_in_as(@archer)
    delete :destroy, id: @malory
    assert_not flash.empty?
    assert_redirected_to root_url
  end

	test "should show own user profile when activated" do
		log_in_as(@archer)
		get :show, id: @archer
		assert_response :success
	end

	test "should redirect other profile when not activated" do
		deactivate_account(@archer)
		log_in_as(@admin)
		get :show, id: @archer
    assert_not flash.empty?
		assert_redirected_to root_url
	end

	test "should redirect own profile when not activated" do
		deactivate_account(@archer)
		log_in_as(@archer)
		get :show, id: @archer
    assert_not flash.empty?
		assert_redirected_to root_url
	end

	test "should redirect show other activated user after disabled setting" do
		turn_off_other_profile_view
		log_in_as(@archer)
		get :show, id: @admin
    assert_not flash.empty?
		assert_redirected_to root_url
	end

	test "should redirect user stats when not logged in" do
		get :get_stats, id: @archer
    assert_not flash.empty?
		assert_redirected_to login_url
	end

	test "should get user stats when logged in" do
		log_in_as(@archer)
		get :get_stats, id: @archer
		assert_response :success
	end

	test "should redirect when requesting user stats of non-existent user" do
		log_in_as(@archer)
		get :get_stats, id: 9
    assert_not flash.empty?
		assert_redirected_to root_url
	end

end
