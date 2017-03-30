class AddProblemParentRef < ActiveRecord::Migration[5.0]
  def change
    add_reference :problems, :parent_problem, index: true
  end
end
