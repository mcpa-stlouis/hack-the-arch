class AddPointerCounterToHints < ActiveRecord::Migration[4.2]
  def change
    add_column :hints, :pointer_counter, :integer
  end
end
