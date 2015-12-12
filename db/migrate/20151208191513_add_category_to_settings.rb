class AddCategoryToSettings < ActiveRecord::Migration
  def change
    add_column :settings, :category, :string
  end
end
