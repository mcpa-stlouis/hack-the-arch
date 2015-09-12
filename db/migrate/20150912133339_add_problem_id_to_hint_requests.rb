class AddProblemIdToHintRequests < ActiveRecord::Migration
  def change
    add_column :hint_requests, :problem_id, :integer
  end
end
