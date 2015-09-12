class AddPriorityToHints < ActiveRecord::Migration
  def change
    add_column :hints, :priority, :integer
  end
end
