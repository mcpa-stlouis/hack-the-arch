class AddPictureToProblem < ActiveRecord::Migration
  def change
    add_column :problems, :picture, :string
  end
end
