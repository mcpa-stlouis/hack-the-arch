require 'test_helper'

class SubmissionsTest < ActionDispatch::IntegrationTest
	def setup
		@non_admin = users(:archer)
	end
		
end
