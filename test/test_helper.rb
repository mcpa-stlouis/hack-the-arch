require 'simplecov'
SimpleCov.start do
  add_filter '/config/'
  add_filter '/lib/'
  add_filter '/vendor/'
  add_filter '/test/'
 
  add_group 'Controllers', 'app/controllers'
  add_group 'Models', 'app/models'
  add_group 'Helpers', 'app/helpers'
  add_group 'Mailers', 'app/mailers'
  add_group 'Views', 'app/views'
end if ENV["COVERAGE"]

ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require "minitest/reporters"
Minitest::Reporters.use!

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Add more helper methods to be used by all tests here...
	def is_logged_in?
		!session[:user_id].nil?
	end
	
	# Logs in a test user.
  def log_in_as(user, options = {})
    password    = options[:password]    || 'password'
    remember_me = options[:remember_me] || '1'
    if integration_test?
      post login_path, session: { email:       user.email,
                                  password:    password,
                                  remember_me: remember_me }
    else
      session[:user_id] = user.id
    end
  end

	def log_out
    if integration_test?
      delete logout_path
    else
			session.delete(:user_id)
    end
	end

	private
		
		# Returns true inside an integration test.
    def integration_test?
      defined?(post_via_redirect)
    end

end
