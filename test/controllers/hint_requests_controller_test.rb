require 'test_helper'

class HintRequestsControllerTest < ActionController::TestCase
	def setup
		@problem = problems(:example_problem)
	end

	test "should redirect request when not logged in" do
    post :create, problem_id: @problem.id
    assert_not flash.empty?
    assert_redirected_to login_url
  end

end
