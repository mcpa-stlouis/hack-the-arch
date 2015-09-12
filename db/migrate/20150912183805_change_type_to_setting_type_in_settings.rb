class ChangeTypeToSettingTypeInSettings < ActiveRecord::Migration
  def change
		rename_column :settings, :type, :setting_type
  end
end
