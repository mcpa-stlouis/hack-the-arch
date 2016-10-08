class AddMessagesToProblem < ActiveRecord::Migration[4.2]
  def change
    add_column :problems, :correct_message, :string
    add_column :problems, :false_message, :string
  end
end
