class AddPictureToProblem < ActiveRecord::Migration[4.2]
  def change
    add_column :problems, :picture, :string
  end
end
