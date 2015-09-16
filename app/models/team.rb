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

	def Team.get_top_teams_score_progression(top_teams = 5)
		cache = Cache.find_by(key: 'top_teams_score_progression')
		if cache && cache.cache_valid
			JSON.parse(cache.value)
		else

			# combine individual team score progressions
			progression = []
			teams = []
			for team in Team.get_top_teams(top_teams)
				progression += team.get_score_progression
				teams.push team.id
			end

			scores = []
			for teams_counter in 0..(teams.count-1)
				scores.push 0
			end

			# build time scaled result
			row = []
			result = []
			scale = 150 # 2.5 minute
			start =  Time.zone.now.to_i - (8 * 60 * 60) # 8 hours
			for time_counter in (start / scale)..(Time.zone.now.to_i / scale)
				row.push(time_counter * scale)
				for teams_counter in 0..(teams.count-1)
					row.push 0
				end
				result.push row
				row = row.dup
				row.clear
			end

			# merge scores with result
			result_it = 0
			progression.sort_by! { |score| score[:created_at] }
			for score in progression
				if score[:created_at].to_i < start
					for teams_counter in 1..teams.count
						if teams[teams_counter-1] == score[:team_id]
							scores[teams_counter-1] = score[:points]
						end
					end
					next
				end

				time = (score[:created_at].to_i / scale) * scale
				loop do
					for score_counter in 0..scores.count-1
						result[result_it][score_counter+1] = scores[score_counter]
					end
 					break if (result_it >= result.length || time == result[result_it][0])
					result_it += 1
				end
				
				row = result[result_it]

				for teams_counter in 1..teams.count
					if teams[teams_counter-1] == score[:team_id]
						scores[teams_counter-1] = score[:points]
					end
					row[teams_counter] = scores[teams_counter-1]
				end
			end

			# Fill out rest of result (time after last score)
 			while result_it < result.length
				for score_counter in 0..scores.count-1
					result[result_it][score_counter+1] = scores[score_counter]
				end
				result_it += 1
			end

			if cache 
				cache.update(result.to_json)
			else
				Cache.create(key: 'top_teams_score_progression', value: result.to_json, cache_valid: true)
			end
			result
		end
	end

	def Team.get_top_teams(top_teams = 5)
		Team.all.sort_by { |team| team.get_score }.reject {|team| team.name == 'admins' }.reverse.first 5
	end

	def Team.invalidate_top_teams_score_progression
		cache = Cache.find_by(key: 'top_teams_score_progression')
		if cache
			cache.invalidate
		end
	end

	def invalidate_score
		cache = Cache.find_by(key: 'team_'+self.id.to_s+'_score')
		if cache
			cache.invalidate
		end
	end

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
		cache = Cache.find_by(key: 'team_'+self.id.to_s+'_score')
		if cache && cache.cache_valid
			cache.value.to_i
		else
			if subtract_hint_points_before_solve?
				score = Submission.where(team_id: self.id).sum(:points) - 
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
			end

			# Update cache
			if cache 
				cache.update(score)
			else
				Cache.create(key: 'team_'+self.id.to_s+'_score', value: score, cache_valid: true)
			end
			score
		end
	end

	def get_score_progression
		# merge hint_requests and submissions
		@submissions = Submission.where(team_id: self.id, correct: true)
		@hint_requests = HintRequest.where(team_id: self.id)
		if !subtract_hint_points_before_solve?
			for hint in @hint_requests
				if !@submissions.bsearch { |sub| sub.problem_id == hint.problem_id }
					@hint_requests.delete!(hint)
				end
			end
		end

		@combined_submissions = @submissions + @hint_requests
		@combined_submissions.sort_by! { |sub| sub.created_at }

		pnts = 0
		result = Array.new
		for sub in @combined_submissions
			pnts += (sub.has_attribute?:correct) ? sub.points : -(sub.points)
			result.push({points: pnts,
									 team_id: sub.team_id,
									 created_at: sub.created_at})
		end
		result

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
