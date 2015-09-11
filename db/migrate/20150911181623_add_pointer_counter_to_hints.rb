class AddPointerCounterToHints < ActiveRecord::Migration
  def change
    add_column :hints, :pointer_counter, :integer
  end
end
