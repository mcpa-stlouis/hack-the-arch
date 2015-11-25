class AddHintsAvailableToBrackets < ActiveRecord::Migration
  def change
    add_column :brackets, :hints_available, :integer
  end
end
