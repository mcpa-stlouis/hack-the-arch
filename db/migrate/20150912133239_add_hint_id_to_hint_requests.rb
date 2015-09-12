class AddHintIdToHintRequests < ActiveRecord::Migration
  def change
    add_column :hint_requests, :hint_id, :integer
  end
end
