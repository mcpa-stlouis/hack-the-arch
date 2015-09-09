class AddPassphraseAndMembersToTeam < ActiveRecord::Migration
  def change
    add_column :teams, :passphrase, :string
    add_column :teams, :members, :string
  end
end
