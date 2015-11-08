class AddCaseSensitiveToProblem < ActiveRecord::Migration
  def change
    add_column :problems, :case_sensitive, :boolean
  end
end
