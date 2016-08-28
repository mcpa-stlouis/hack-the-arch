class AddFieldsToCache < ActiveRecord::Migration[4.2]
  def change
    add_column :caches, :key, :string
    add_column :caches, :value, :string
  end
end
