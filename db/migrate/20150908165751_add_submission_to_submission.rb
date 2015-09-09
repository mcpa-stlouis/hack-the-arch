class AddSubmissionToSubmission < ActiveRecord::Migration
  def change
    add_column :submissions, :submission, :string
  end
end
