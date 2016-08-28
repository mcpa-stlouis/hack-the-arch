class AddTypeToSettings < ActiveRecord::Migration[4.2]
  def change
    add_column :settings, :type, :string
  end
end
