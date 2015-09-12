class AddTeamIdToHintRequests < ActiveRecord::Migration
  def change
    add_column :hint_requests, :team_id, :integer
  end
end
