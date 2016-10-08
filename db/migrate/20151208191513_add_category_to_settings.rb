class AddCategoryToSettings < ActiveRecord::Migration[4.2]
  def change
    add_column :settings, :category, :string
  end
end
