class Submission < ActiveRecord::Base
  before_save :invalidate_cache
	validates :points,  presence: true, numericality: { only_integer: true, greater_than: 0 }
	validates :correct, presence: true, inclusion: { in: [true, false] }
	validates :user_id,  presence: true, numericality: { only_integer: true, greater_than: 0 }
	validates :team_id,  presence: true, numericality: { only_integer: true, greater_than: 0 }
	validates :problem_id,  presence: true, numericality: { only_integer: true, greater_than: 0 }
	validates :submission,  presence: true, length: { maximum: 500 }

	def Submission.get_solves_for_problem(problem_id)
		count = 0
		for submission in Submission.all
			count += (submission.problem_id == problem_id && 
								submission.correct? && 
								submission.team_id != 1) ? 1 : 0
		end
		count
	end

	private
		def invalidate_cache
			if self.correct
				Team.invalidate_top_teams_score_progression
				Team.find(self.team_id).invalidate_score
				Team.find(self.user_id).invalidate_score
			end
		end
end
