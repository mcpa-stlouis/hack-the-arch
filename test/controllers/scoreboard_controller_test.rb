require 'test_helper'

class ScoreboardControllerTest < ActionController::TestCase
	def setup
		@user = users(:archer)
		@team = teams(:example_team)
	end

	test "should get index" do
    get :index
    assert_response :success
  end
end
