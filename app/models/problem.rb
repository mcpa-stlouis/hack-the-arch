class Problem < ActiveRecord::Base
	validates :name,  presence: true, length: { maximum: 50 }
	validates :category,  presence: true, length: { maximum: 100 }
	validates :description,  presence: true, length: { maximum: 500 }
	validates :points,  presence: true, inclusion: { in: 0..1000 }

	def solved_by?(team_id)
		Submission.find_by(team_id: team_id,
											 problem_id: self.id,
											 correct: true)
	end

	def add(hint_id)
		hint = Hint.find(hint_id)
		save_hints(hints_array.push(hint.id.to_s))
		hint.increment_pointer_counter
	end
	
	def remove(hint_id)
		if self.hints 
			hint = Hint.find(hint_id)
			save_hints(hints_array.reject! { |id| id == hint.id.to_s })
			hint.decrement_pointer_counter
		end
	end

	def hints_array
		if !self.hints # Lazy Instantiation
			Array.new
		else
			self.hints.split(',')
		end
	end

	def save_hints(hints_array)
		update_attribute(:hints, hints_array.join(','))
	end

end
