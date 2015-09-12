class AddPointsToHintRequests < ActiveRecord::Migration
  def change
    add_column :hint_requests, :points, :integer
  end
end
