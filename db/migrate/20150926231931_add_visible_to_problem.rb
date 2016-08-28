class AddVisibleToProblem < ActiveRecord::Migration[4.2]
  def change
    add_column :problems, :visible, :boolean
  end
end
