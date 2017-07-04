class UserMailer < ApplicationMailer
  include SettingsHelper

  def account_activation(user)
    @user = user
    @competition_name = competition_name
    @admin_email = contact_email
    mail to: user.email, subject: "[#{competition_name}] Account activation"
  end

  def account_authorized(user)
    @user = user
    @competition_name = competition_name
    @admin_email = contact_email
    mail to: user.email, subject: "[#{competition_name}] Account authorized!"
  end

  def password_reset(user)
    @user = user
    @competition_name = competition_name
    @admin_email = contact_email
    mail to: user.email, subject: "[#{competition_name}] Password reset"
  end
end
