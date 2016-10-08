class AddHintsToProblem < ActiveRecord::Migration[4.2]
  def change
    add_column :problems, :hints, :string
  end
end
