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
end
