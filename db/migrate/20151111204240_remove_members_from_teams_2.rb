class RemoveMembersFromTeams2 < ActiveRecord::Migration[4.2]
  def change
    remove_column :teams, :members
  end
end
