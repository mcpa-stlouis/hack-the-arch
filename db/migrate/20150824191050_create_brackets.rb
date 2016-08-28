class CreateBrackets < ActiveRecord::Migration[4.2]
  def change
    create_table :brackets do |t|
      t.string :name
      t.integer :priority

      t.timestamps null: false
    end
  end
end
