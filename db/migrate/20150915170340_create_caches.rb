class CreateCaches < ActiveRecord::Migration[4.2]
  def change
    create_table :caches do |t|

      t.timestamps null: false
    end
  end
end
