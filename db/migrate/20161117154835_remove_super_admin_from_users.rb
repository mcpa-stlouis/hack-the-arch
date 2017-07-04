class RemoveSuperAdminFromUsers < ActiveRecord::Migration[5.0]
  def change
    remove_column :users, :super_admin
  end
end
