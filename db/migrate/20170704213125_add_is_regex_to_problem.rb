class AddIsRegexToProblem < ActiveRecord::Migration[5.0]
  def change
    add_column :problems, :regex, :boolean
  end
end
