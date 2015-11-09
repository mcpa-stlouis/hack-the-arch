class Bracket < ActiveRecord::Base
	has_many :teams, dependent: :destroy
	validates :name,  presence: true, length: { maximum: 50 }
	validates :priority,  presence: true, numericality: { only_integer: true, greater_than: 0 }
	validates :hints_available,  presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
end
