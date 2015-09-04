require 'test_helper'

class UserMailerTest < ActionMailer::TestCase
  test "account_activation" do
		user = users(:example_user)
    user.activation_token = User.new_token
    mail = UserMailer.account_activation(user)
    assert_equal "[HackTheArch] Account activation", mail.subject
    assert_equal [user.email], mail.to
    assert_equal ["noreply@example.com"], mail.from
    assert_match user.fname,              mail.body.encoded
    assert_match user.activation_token,   mail.body.encoded
    assert_match CGI::escape(user.email), mail.body.encoded
  end

  test "password_reset" do
    mail = UserMailer.password_reset
    assert_equal "Password reset", mail.subject
    assert_equal ["to@example.org"], mail.to
    assert_equal ["noreply@example.com"], mail.from
    assert_match "Hi", mail.body.encoded
  end

end
