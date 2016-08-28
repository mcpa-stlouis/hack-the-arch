class AddPaidToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :paid, :boolean
  end
end
