class Cache < ActiveRecord::Base
	validates :cache_valid, presence: true, inclusion: { in: [true, false] }
	validates :key,  presence: true, length: { maximum: 255 }
	validates :value,  presence: true, length: { maximum: 4096 }

	def invalidate
		update_attribute :cache_valid, false
	end

	def update(value)
		update_attribute :value, value
		update_attribute :cache_valid, true
	end
end
