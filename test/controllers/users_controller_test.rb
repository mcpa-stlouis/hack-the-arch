require 'test_helper'

class UsersControllerTest < ActionController::TestCase
	def setup
		@user = users(:example_user)
		@other_user = users(:archer)
	end

  test "should get new" do
    get :new
    assert_response :success
  end

	test "should redirect edit when not logged in" do
    get :edit, id: @user
    assert_not flash.empty?
    assert_redirected_to login_url
  end

  test "should redirect update when not logged in" do
    patch :update, id: @user, user: { fname: @user.fname, lname: @user.lname, email: @user.email }
    assert_not flash.empty?
    assert_redirected_to login_url
  end

	test "should redirect edit when logged in as wrong user" do
    log_in_as(@other_user)
    get :edit, id: @user
    assert flash.empty?
    assert_redirected_to root_url
  end

  test "should redirect update when logged in as wrong user" do
    log_in_as(@other_user)
    patch :update, id: @user, user: { fname: @user.fname, lname: @user.lname, email: @user.email }
    assert flash.empty?
    assert_redirected_to root_url
  end

end
