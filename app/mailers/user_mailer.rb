class UserMailer < ApplicationMailer

	# TODO Set subject line dynamically using configured domain
	def account_activation(user)
    @user = user
    mail to: user.email, subject: "[HackTheArch] Account activation"
  end

  def password_reset(user)
		@user = user
		mail to: user.email, subject: "[HackTheArch] Password reset"
  end
end
