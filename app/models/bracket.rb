class Bracket < ActiveRecord::Base
	validates :name,  presence: true, length: { maximum: 50 }
	validates :priority,  presence: true, numericality: { only_integer: true, greater_than: 0 }
end
