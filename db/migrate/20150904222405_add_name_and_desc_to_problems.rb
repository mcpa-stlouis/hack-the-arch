class AddNameAndDescToProblems < ActiveRecord::Migration[4.2]
  def change
    add_column :problems, :name, :string
    add_column :problems, :description, :string
  end
end
