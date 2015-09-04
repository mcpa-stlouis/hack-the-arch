class UserMailer < ApplicationMailer

	# TODO Set subject line dynamically using configured domain
	def account_activation(user)
    @user = user
    mail to: user.email, subject: "[HackTheArch] Account activation"
  end

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.password_reset.subject
  #
  def password_reset
    @greeting = "Hi"

    mail to: "to@example.org"
  end
end
