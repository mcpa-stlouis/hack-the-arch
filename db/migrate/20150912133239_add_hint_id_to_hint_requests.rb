class AddHintIdToHintRequests < ActiveRecord::Migration[4.2]
  def change
    add_column :hint_requests, :hint_id, :integer
  end
end
