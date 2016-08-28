class CreateSubmissions < ActiveRecord::Migration[4.2]
  def change
    create_table :submissions do |t|

      t.timestamps null: false
    end
  end
end
