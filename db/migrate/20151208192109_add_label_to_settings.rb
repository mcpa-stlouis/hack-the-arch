class AddLabelToSettings < ActiveRecord::Migration
  def change
    add_column :settings, :label, :string
  end
end
