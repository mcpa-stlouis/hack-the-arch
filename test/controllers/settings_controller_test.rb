require 'test_helper'

class SettingsControllerTest < ActionController::TestCase
	def setup
		@setting = settings(:setting_competition_name)
		@non_admin = users(:archer)
		@admin = users(:example_user)
	end

  test "should redirect edit when not admin" do
    log_in_as(@non_admin)
		get :edit, admin_path
    assert_not flash.empty?
    assert_redirected_to root_url
  end

  test "should redirect update when not admin" do
    log_in_as(@non_admin)
    patch :update, settings_path, admin: { "1": { id: @setting.id, name: @setting.name, value: @setting.value} }
    assert_not flash.empty?
    assert_redirected_to root_url
  end

	test "should get edit when admin" do
		log_in_as(@admin)
		get :edit, admin_path
		assert_response :success
	end

	test "should update successfully when admin" do
		log_in_as(@admin)
    patch :update, settings_path, admin: { "1": { id: @setting.id, name: @setting.name, value: @setting.value} }
		assert_redirected_to admin_url
	end

end
