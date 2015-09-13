class Setting < ActiveRecord::Base
	validates :name, presence: true, length: { maximum: 255 }, uniqueness: true
	validates :value, presence: true, length: { maximum: 255 }
	validates :setting_type, presence: true, length: { maximum: 255 }
end
