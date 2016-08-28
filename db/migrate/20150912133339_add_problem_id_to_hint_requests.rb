class AddProblemIdToHintRequests < ActiveRecord::Migration[4.2]
  def change
    add_column :hint_requests, :problem_id, :integer
  end
end
