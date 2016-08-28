class AddPointsToSubmission < ActiveRecord::Migration[4.2]
  def change
    add_column :submissions, :points, :integer
  end
end
