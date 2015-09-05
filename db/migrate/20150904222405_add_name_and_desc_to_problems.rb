class AddNameAndDescToProblems < ActiveRecord::Migration
  def change
    add_column :problems, :name, :string
    add_column :problems, :description, :string
  end
end
