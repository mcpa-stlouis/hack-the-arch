class ValidateAtCapacity < ActiveModel::Validator

  def validate(record)
    if record.at_capacity?
      record.errors[] << 'Team has reached capcity'
    end
  end
end

class Team < ActiveRecord::Base
	include ActiveModel::Validations
	include SettingsHelper
	validates :name,  presence: true, length: { maximum: 50 },
										uniqueness: true
	validates :passphrase,  presence: true, length: { minimum: 6 }
	validates_with ValidateAtCapacity

	def add(user)
		if members_array.count < max_members_per_team
			save_members(members_array.push(user.id.to_s))
		else
			return false
		end
	end
	
	def remove(user)
		if self.members 
			save_members(members_array.reject! { |member| member == user.id.to_s })
		end
	end

	def at_capacity?
		if self.members 
			members_array.count >= max_members_per_team
		end
	end

	def get_score
		if subtract_hint_points_before_solve?
			Submission.where(team_id: self.id).sum(:points) - 
			HintRequest.where(team_id: self.id).sum(:points)
		else
			score = 0
			for submission in Submission.where(team_id: self.id)
				if submission.correct
					score = score + submission.points
					for hint in HintRequest.where(team_id: self.id, problem_id: submission.problem_id)
						score = score - hint.points
					end
				end
			end
			score
		end
			
	end

	def get_hints_requested(problem_id)
		HintRequest.where(team_id: self.id, problem_id: problem_id)
	end

	def members_array
		if !self.members # Lazy Instantiation
			Array.new
		else
			self.members.split(',')
		end
	end

	def save_members(members_array)
		update_attribute(:members, members_array.join(','))
	end

	def authenticate(passphrase)
		passphrase == self.passphrase
	end

	private
		def max_members_per_team
			Setting.find_by(name: 'max_members_per_team').value.to_i
		end
end
