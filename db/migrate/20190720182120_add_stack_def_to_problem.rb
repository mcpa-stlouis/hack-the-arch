class AddStackDefToProblem < ActiveRecord::Migration[5.2]
  def change
    add_column :problems, :stack, :string
    add_column :problems, :network, :string
  end
end
