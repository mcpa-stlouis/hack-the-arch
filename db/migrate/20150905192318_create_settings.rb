class CreateSettings < ActiveRecord::Migration[4.2]
  def change
    create_table :settings do |t|
      t.string :name
      t.string :value

      t.timestamps null: false
    end
  end
end
