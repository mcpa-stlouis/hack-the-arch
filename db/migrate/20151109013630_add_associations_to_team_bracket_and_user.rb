class AddAssociationsToTeamBracketAndUser < ActiveRecord::Migration
  def change
		add_index :teams, :bracket_id
		add_index :users, :team_id
		add_index :submissions, :team_id
		add_index :submissions, :user_id
		add_index :hint_requests, :team_id
		add_index :hint_requests, :user_id
  end
end
