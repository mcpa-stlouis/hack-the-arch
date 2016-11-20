class AddAuthorizedToUser < ActiveRecord::Migration[5.0]
  def up
    add_column :users, :super_admin, :boolean, default: false # will receive e-mail
    add_column :users, :authorized, :boolean, default: false
    add_column :users, :authorized_at, :datetime
    User.all.update_all authorized_at: Time.zone.now
    User.all.update_all authorized: true
  end

  def down
    remove_columns :users, :authorized, :authorized_at, :super_admin
  end
end
