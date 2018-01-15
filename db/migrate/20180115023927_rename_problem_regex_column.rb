class RenameProblemRegexColumn < ActiveRecord::Migration[5.1]
  def self.up
    rename_column :problems, :regex, :solution_regex
  end

  def self.down
    rename_column :problems, :solution_regex, :regex
  end
end
