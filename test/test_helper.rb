require 'coveralls'
Coveralls.wear!

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

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Add more helper methods to be used by all tests here...
  def is_logged_in?
    !session[:user_id].nil?
  end
  
  # Log in as a particular user.
  def log_in_as(user)
    session[:user_id] = user.id
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

class ActionDispatch::IntegrationTest

  # Log in as a particular user.
  def log_in_as(user, password: 'password', remember_me: '1')
    post login_path, params: { session: { email: user.email,
                                          password: password,
                                          remember_me: remember_me } }
  end
end
