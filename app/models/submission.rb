class Submission < ActiveRecord::Base
  before_save :invalidate_cache
	belongs_to :user
	belongs_to :team
	belongs_to :problem
	validates :points,  presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
	validates :correct, inclusion: { in: [true, false] }
	validates :correct, exclusion: { in: [nil] }
	validates :user_id,  presence: true, numericality: { only_integer: true, greater_than: 0 }
	validates :team_id,  presence: true, numericality: { only_integer: true, greater_than: 0 }
	validates :problem_id,  presence: true, numericality: { only_integer: true, greater_than: 0 }
	validates :submission,  presence: true, length: { maximum: 500 }

	def Submission.get_solves_for_problem(problem_id)
		Submission.all.where(problem: problem_id, correct: true).where.not(team: 1).count
	end

	def Submission.get_number_of_submissions_for_team(problem_id, team_id)
		Submission.where(team: team_id, problem: problem_id).count
	end

	private
		def invalidate_cache
			if self.correct
				Team.invalidate_top_teams_score_progression
				Team.find(self.team_id).invalidate_score
				User.find(self.user_id).invalidate_score
			end
		end
end
