class AddLabelToSettings < ActiveRecord::Migration[4.2]
  def change
    add_column :settings, :label, :string
  end
end
