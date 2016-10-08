class AddTooltipToSettings < ActiveRecord::Migration[4.2]
  def change
    add_column :settings, :tooltip, :string
  end
end
