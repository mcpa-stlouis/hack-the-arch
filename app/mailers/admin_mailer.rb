class AdminMailer < ApplicationMailer
  include SettingsHelper

  def new_user(user)
    @user = user
    mail to: admin_auth_email, subject: "[#{competition_name}] New User"
  end
end
