class AdminMailer < ApplicationMailer
	include SettingsHelper

  def new_user(admin, user)
    @user = user
    mail to: admin.email, subject: "[#{competition_name}] New User"
  end
end
