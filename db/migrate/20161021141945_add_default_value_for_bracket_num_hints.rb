class AddDefaultValueForBracketNumHints < ActiveRecord::Migration[5.0]
  def change
    change_column :brackets, :hints_available, :integer, :default => 0
  end
end
