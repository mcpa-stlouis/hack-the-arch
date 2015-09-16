class Submission < ActiveRecord::Base
  before_save :invalidate_cache
	validates :points,  presence: true, numericality: { only_integer: true, greater_than: 0 }
	validates :correct, presence: true, inclusion: { in: [true, false] }
	validates :user_id,  presence: true, numericality: { only_integer: true, greater_than: 0 }
	validates :team_id,  presence: true, numericality: { only_integer: true, greater_than: 0 }
	validates :problem_id,  presence: true, numericality: { only_integer: true, greater_than: 0 }
	validates :submission,  presence: true, length: { maximum: 500 }

	private
		def invalidate_cache
			if self.correct
				Team.invalidate_top_teams_score_progression
				Team.find(self.team_id).invalidate_score
			end
		end
end
