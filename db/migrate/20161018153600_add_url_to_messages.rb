class AddUrlToMessages < ActiveRecord::Migration[5.0]
  def change
    add_column :messages, :url, :string
  end
end
