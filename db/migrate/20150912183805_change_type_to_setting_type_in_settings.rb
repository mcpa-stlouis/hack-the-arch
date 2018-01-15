class ChangeTypeToSettingTypeInSettings < ActiveRecord::Migration[4.2]
  def change
    rename_column :settings, :type, :setting_type
  end
end
