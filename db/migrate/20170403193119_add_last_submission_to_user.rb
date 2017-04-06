class AddLastSubmissionToUser < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :last_submission, :datetime
  end
end
