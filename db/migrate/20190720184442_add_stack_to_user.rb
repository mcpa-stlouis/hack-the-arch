class AddStackToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :stack_expiry, :datetime
    add_column :users, :container_id, :string
    add_column :users, :problem_id, :integer
  end
end
