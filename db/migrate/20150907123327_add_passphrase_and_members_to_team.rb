class AddPassphraseAndMembersToTeam < ActiveRecord::Migration[4.2]
  def change
    add_column :teams, :passphrase, :string
    add_column :teams, :members, :string
  end
end
