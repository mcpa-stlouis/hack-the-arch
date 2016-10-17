class CreateNotifications < ActiveRecord::Migration[5.0]
  def change
    create_table :notifications do |t|
      t.string :message
      t.string :priority

      t.timestamps
    end
  end
end
