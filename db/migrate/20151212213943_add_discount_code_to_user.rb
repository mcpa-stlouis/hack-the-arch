class AddDiscountCodeToUser < ActiveRecord::Migration
  def change
    add_column :users, :discount_code, :string
  end
end
