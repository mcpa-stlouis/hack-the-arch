class AddDetailsToSubmissions < ActiveRecord::Migration[4.2]
  def change
    add_column :submissions, :team_id, :integer
    add_column :submissions, :user_id, :integer
    add_column :submissions, :correct, :boolean
    add_column :submissions, :problem_id, :integer
  end
end
