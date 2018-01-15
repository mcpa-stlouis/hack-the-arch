class FixCaseSensitiveColumnName < ActiveRecord::Migration[4.2]
  def change
    rename_column :problems, :case_sensitive, :solution_case_sensitive
  end
end
