class AddPointsToSubmission < ActiveRecord::Migration
  def change
    add_column :submissions, :points, :integer
  end
end
