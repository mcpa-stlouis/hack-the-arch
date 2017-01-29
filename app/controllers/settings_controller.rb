class SettingsController < ApplicationController
  before_action :admin_user, only: [:index, :edit, :update]

  def edit
    # Ordering General first, then all others
    @categories = ["General"]
    @categories += Setting.where.not(category: 'General').distinct.pluck(:category).sort

    @general = Setting.where(category: 'General').order(id: :asc)
    @other_settings = Setting.where.not(category: 'General').order(category: :asc, id: :asc)
    @settings = @general + @other_settings

    @brackets = Bracket.all.order(priority: :asc)
    @users = User.all
    @teams = Team.all
    @num_challenges = Problem.where(visible: true).count
  end
  
  def update
    error = false
    settings = params[:admin]

    settings.each do |key, setting|
      to_update = Setting.find(setting[:id])

      if to_update.setting_type == 'boolean'
        to_update.value = (setting[:value]) ? "1" : "0"
      else
        to_update.value = setting[:value]
      end

      error = (to_update.save) ? false : true
    end

    if error
      flash[:danger] = "Failed to update database. Try again."
    else
      flash[:success] = "Successfully updated changes."
    end
    redirect_to admin_url
  end

end
