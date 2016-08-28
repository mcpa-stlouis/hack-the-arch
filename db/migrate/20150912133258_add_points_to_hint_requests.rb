class AddPointsToHintRequests < ActiveRecord::Migration[4.2]
  def change
    add_column :hint_requests, :points, :integer
  end
end
