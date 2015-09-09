class AddSolutionToProblem < ActiveRecord::Migration
  def change
    add_column :problems, :solution, :string
  end
end
