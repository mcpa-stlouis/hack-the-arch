require 'test_helper'

class SettingsControllerTest < ActionController::TestCase
	def setup
		@setting = settings(:setting_competition_name)
		@non_admin = users(:archer)
	end

  test "should redirect edit when not admin" do
    log_in_as(@non_admin)
		get :edit, admin_path
    assert_not flash.empty?
    assert_redirected_to root_url
  end

  test "should redirect update when not admin" do
    log_in_as(@non_admin)
    patch :update, settings_path, admin: { "1": { name: @setting.name, value: @setting.value} }
    assert_not flash.empty?
    assert_redirected_to root_url
  end

end
