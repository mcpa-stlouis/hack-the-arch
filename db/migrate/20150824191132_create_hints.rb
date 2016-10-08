class CreateHints < ActiveRecord::Migration[4.2]
  def change
    create_table :hints do |t|
      t.string :hint
      t.integer :points

      t.timestamps null: false
    end
  end
end
