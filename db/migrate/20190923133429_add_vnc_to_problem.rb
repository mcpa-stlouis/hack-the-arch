class AddVncToProblem < ActiveRecord::Migration[5.2]
  def change
    add_column :problems, :vnc, :boolean
  end
end
