class AddHintsToProblem < ActiveRecord::Migration
  def change
    add_column :problems, :hints, :string
  end
end
