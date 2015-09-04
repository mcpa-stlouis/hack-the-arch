require 'test_helper'

class UsersEditTest < ActionDispatch::IntegrationTest
	def setup
		@user = users(:example_user)
	end

	test "unsuccessful edit" do
		log_in_as(@user)
    get edit_user_path(@user)
    assert_template 'users/edit'
    patch user_path(@user), user: { name:  "",
                                    email: "foo@invalid",
                                    password:              "foo",
                                    password_confirmation: "bar" }
    assert_template 'users/edit'
	end

	test "successful edit with friendly redirect" do
    get edit_user_path(@user)
		log_in_as(@user)
		assert_redirected_to edit_user_path(@user)
		fname = "Foo"
		lname = "Bar"
		email = "foo@bar.com"
    patch user_path(@user), user: { fname:  fname,
                                    lname:  lname,
                                    email: email,
                                    password:              "",
                                    password_confirmation: "" }
		assert_not flash.empty?
		assert_redirected_to @user
		@user.reload
		assert_equal fname, @user.fname
		assert_equal lname, @user.lname
		assert_equal email, @user.email
  end

end
