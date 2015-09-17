class AddCacheValidToCache < ActiveRecord::Migration
  def change
    add_column :caches, :cache_valid, :boolean
  end
end
