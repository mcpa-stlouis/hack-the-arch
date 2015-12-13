class UserMailer < ApplicationMailer
	include SettingsHelper

	# TODO Set subject line dynamically using configured domain
	def account_activation(user)
    @user = user
    mail to: user.email, subject: "[#{competition_name}] Account activation"
  end

  def password_reset(user)
		@user = user
		mail to: user.email, subject: "[#{competition_name}] Password reset"
  end
end
