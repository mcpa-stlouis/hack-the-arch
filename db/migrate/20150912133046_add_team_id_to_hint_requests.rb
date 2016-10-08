class AddTeamIdToHintRequests < ActiveRecord::Migration[4.2]
  def change
    add_column :hint_requests, :team_id, :integer
  end
end
