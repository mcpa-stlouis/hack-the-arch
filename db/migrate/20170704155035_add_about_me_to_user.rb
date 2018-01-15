class AddAboutMeToUser < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :about, :string
  end
end
