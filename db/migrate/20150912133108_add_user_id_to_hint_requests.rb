class AddUserIdToHintRequests < ActiveRecord::Migration[4.2]
  def change
    add_column :hint_requests, :user_id, :integer
  end
end
