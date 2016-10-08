class AddHintsAvailableToBrackets < ActiveRecord::Migration[4.2]
  def change
    add_column :brackets, :hints_available, :integer
  end
end
