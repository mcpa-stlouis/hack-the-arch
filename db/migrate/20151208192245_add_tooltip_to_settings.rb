class AddTooltipToSettings < ActiveRecord::Migration
  def change
    add_column :settings, :tooltip, :string
  end
end
