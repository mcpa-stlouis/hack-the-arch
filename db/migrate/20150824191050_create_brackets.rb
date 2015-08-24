class CreateBrackets < ActiveRecord::Migration
  def change
    create_table :brackets do |t|
      t.string :name
      t.integer :priority

      t.timestamps null: false
    end
  end
end
