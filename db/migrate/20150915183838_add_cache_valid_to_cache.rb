class AddCacheValidToCache < ActiveRecord::Migration[4.2]
  def change
    add_column :caches, :cache_valid, :boolean
  end
end
