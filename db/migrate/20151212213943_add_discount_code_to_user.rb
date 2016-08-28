class AddDiscountCodeToUser < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :discount_code, :string
  end
end
