class AddSolutionToProblem < ActiveRecord::Migration[4.2]
  def change
    add_column :problems, :solution, :string
  end
end
