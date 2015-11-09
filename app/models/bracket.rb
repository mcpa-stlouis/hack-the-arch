class Bracket < ActiveRecord::Base
	has_many :teams, dependent: :destroy
	validates :name,  presence: true, length: { maximum: 50 }
	validates :priority,  presence: true, numericality: { only_integer: true, greater_than: 0 }
end
