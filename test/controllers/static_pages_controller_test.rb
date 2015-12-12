require 'test_helper'

class StaticPagesControllerTest < ActionController::TestCase
	def setup
		@competition_name = settings(:setting_competition_name)
	end

  test "should get home" do
    get :home
    assert_response :success
		assert_select "title", @competition_name.value
  end

  test "should get contact" do
    get :contact
    assert_response :success
		assert_select "title", "Contact | #{@competition_name.value}"
  end

  test "should get help" do
    get :help
    assert_response :success
		assert_select "title", "Help | #{@competition_name.value}"
  end

	test "should get about" do
    get :about
    assert_response :success
		assert_select "title", "About | #{@competition_name.value}"
  end

end
