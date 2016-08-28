class AddSubmissionToSubmission < ActiveRecord::Migration[4.2]
  def change
    add_column :submissions, :submission, :string
  end
end
