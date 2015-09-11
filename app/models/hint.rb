class Hint < ActiveRecord::Base
	validates :hint, presence: true, length: { maximum: 500 }
	validates :points,  presence: true, inclusion: { in: 0..1000 }

	def decrement_pointer_counter
		if self.pointer_counter <= 1
			self.destroy
		else
			update_attribute(:pointer_counter, self.pointer_counter - 1)
		end
	end

	def increment_pointer_counter
		if self.pointer_counter
			update_attribute(:pointer_counter, self.pointer_counter + 1)
		else
			update_attribute(:pointer_counter, 1)
		end
	end

end
