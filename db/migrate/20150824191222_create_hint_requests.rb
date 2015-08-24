class CreateHintRequests < ActiveRecord::Migration
  def change
    create_table :hint_requests do |t|

      t.timestamps null: false
    end
  end
end
