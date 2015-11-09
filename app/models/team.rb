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
	has_many :users, dependent: :destroy, inverse_of: :team
	has_many :hint_requests, inverse_of: :team
	has_many :submissions, inverse_of: :team
	belongs_to :bracket
	validates :name,  presence: true, length: { maximum: 50 },
										uniqueness: true
	validates :passphrase,  presence: true, 
													length: { minimum: 6 }
	validates :bracket_id, presence: true, 
												 numericality: { only_integer: true, greater_than: 0 }
	validate  :bracket_exists
	validates_with ValidateAtCapacity

	def Team.get_top_teams_score_progression(top_teams = 5)
		cache = Cache.find_by(key: 'top_teams_score_progression')
		if cache && cache.cache_valid
			JSON.parse(cache.value)
		else

			# combine individual team score progressions
			progressions = []
			for team in Team.get_top_teams(top_teams)
				progressions.push team.get_score_progression
			end

			# build result
			column_index = 0
			result = {}
			result_scores = []
			result_teams = {}
			for progression in progressions
				if progression.empty?
					next
				end

				col_label = "x#{column_index.to_s}"
				col_team_name = Team.find(progression[0][:team]).name
				column_index += 1

				x = []
				x.push col_label

				y = []
				y.push col_team_name

				result_teams[col_team_name] = col_label

				for entry in progression
					x.push entry[:created_at].to_i.to_s
					y.push entry[:points].to_s
				end
				result_scores.push x
				result_scores.push y
			end

			result[:teams] = result_teams
			result[:scores] = result_scores

			if cache 
				cache.update(result.to_json)
			else
				Cache.create(key: 'top_teams_score_progression', value: result.to_json, cache_valid: true)
			end
			JSON.parse(result.to_json)
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

	def at_capacity?
		self.users.count >= max_members_per_team
	end

	def get_score
		cache = Cache.find_by(key: 'team_'+self.id.to_s+'_score')
		if cache && cache.cache_valid
			cache.value.to_i
		else
			if subtract_hint_points_before_solve?
				score = self.submissions.sum(:points) - self.hint_requests.sum(:points)
			else
				score = 0
				for submission in self.submissions.where(correct: true)
					score = score + submission.points
					for hint in self.hint_requests.where(problem: submission.problem) 
						score = score - hint.points
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
		@submissions = self.submissions.where(correct: true)
		if subtract_hint_points_before_solve?
			@hint_requests = self.hint_requests
		else
			@hint_requests = self.hint_requests.where(problem_id: @submissions.select(:problem_id))
		end

		@combined_submissions = @submissions + @hint_requests
		@combined_submissions.sort_by! { |sub| sub.created_at }

		pnts = 0
		result = Array.new
		for sub in @combined_submissions
			pnts += (sub.has_attribute?:correct) ? sub.points : -(sub.points)
			result.push({points: pnts,
									 team: sub.team_id,
									 created_at: sub.created_at})
		end
		result

	end

	def get_hints_requested(problem_id)
		self.hint_requests.where(problem: problem_id)
	end

	def get_most_recent_solve
		sub = self.submissions.last
		sub.created_at if sub
	end

	def authenticate(passphrase)
		passphrase == self.passphrase
	end

	private
		def max_members_per_team
			Setting.find_by(name: 'max_members_per_team').value.to_i
		end

    def bracket_exists
      if !Bracket.exists?(bracket_id)
        errors.add(:bracket_id, "Couldn't find bracket_id with specified id")
      end
    end
end
