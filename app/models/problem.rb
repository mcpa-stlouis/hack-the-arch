class Problem < ActiveRecord::Base
	mount_uploader :picture, PictureUploader
	has_many :hint_requests, dependent: :destroy, inverse_of: :problem
	has_many :submissions, dependent: :destroy, inverse_of: :problem
	validates :name,  presence: true, length: { maximum: 50 }
	validates :category,  presence: true, length: { maximum: 100 }
	validates :description,  presence: true, length: { maximum: 500 }
	validates :points,  presence: true, numericality: { only_integer: true, greater_than: 0 }
	validates :visible, inclusion: { in: [true, false] }
	validates :visible, exclusion: { in: [nil] }
	validates :hints, absence: true, on: :create
	validates :solution_case_sensitive, inclusion: { in: [true, false] }
	validates :solution_case_sensitive, exclusion: { in: [nil] }
	validate  :picture_size

	def solved_by?(team_id)
		self.submissions.where(team: team_id, correct: true).count > 0 ? true : false
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

	def remove_all_hints
		if self.hints 
			hint_array = hints_array
			# IMPORTANT: Must save hints before decrementing pointers
			save_hints(hint_array.clear)
			for hint in hint_array
				Hint.find_by(id: hint.to_i).decrement_pointer_counter
			end
		end
	end

	def hints_array
		if !self.hints # Lazy Instantiation
			Array.new
		else
			self.hints.split(',').sort_by{ |id| Hint.find(id).priority }
		end
	end

	def number_of_hints_available
		self.hints_array.count
	end

	def get_next_hint(team_id, problem_id)
		@team = Team.find(team_id)
		num_hints_requested = @team.get_hints_requested(problem_id).count
		hints_array[num_hints_requested]
	end

	private

		# Don't give access to the array directly 
		def save_hints(hints_array)
			update_attribute(:hints, hints_array.join(','))
		end
	
		# Validates the size of an uploaded picture.
    def picture_size
      if picture.size > 5.megabytes
        errors.add(:picture, "should be less than 5MB")
      end
    end

end
