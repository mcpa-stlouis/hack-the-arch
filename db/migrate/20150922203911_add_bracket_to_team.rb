class AddBracketToTeam < ActiveRecord::Migration
  def change
    add_column :teams, :bracket_id, :integer
  end
end
