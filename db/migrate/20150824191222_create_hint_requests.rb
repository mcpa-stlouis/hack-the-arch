class CreateHintRequests < ActiveRecord::Migration[4.2]
  def change
    create_table :hint_requests do |t|

      t.timestamps null: false
    end
  end
end
