class AddCacheValidToCache < ActiveRecord::Migration
  def change
		remove_column :caches, :valid
    add_column :caches, :cache_valid, :boolean
  end
end
