class AddBracketToTeam < ActiveRecord::Migration[4.2]
  def change
    add_column :teams, :bracket_id, :integer
  end
end
