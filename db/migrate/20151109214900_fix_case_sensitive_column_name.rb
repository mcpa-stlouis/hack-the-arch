class FixCaseSensitiveColumnName < ActiveRecord::Migration
  def change
		rename_column :problems, :case_sensitive, :solution_case_sensitive
  end
end
