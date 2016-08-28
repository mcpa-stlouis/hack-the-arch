class AddPriorityToHints < ActiveRecord::Migration[4.2]
  def change
    add_column :hints, :priority, :integer
  end
end
