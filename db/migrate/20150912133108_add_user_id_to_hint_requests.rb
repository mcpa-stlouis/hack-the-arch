class AddUserIdToHintRequests < ActiveRecord::Migration
  def change
    add_column :hint_requests, :user_id, :integer
  end
end
