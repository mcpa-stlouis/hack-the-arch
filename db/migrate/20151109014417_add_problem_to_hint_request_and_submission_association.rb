class AddProblemToHintRequestAndSubmissionAssociation < ActiveRecord::Migration
  def change
		add_index :submissions, :problem_id
		add_index :hint_requests, :problem_id
  end
end
