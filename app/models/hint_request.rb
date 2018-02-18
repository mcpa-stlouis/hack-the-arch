class HintRequest < ActiveRecord::Base
  before_save :invalidate_cache
  belongs_to :user, touch: true
  belongs_to :team, touch: true
  belongs_to :problem, touch: true
  validates :team_id,  presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :user_id,  presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :hint_id,  presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :points,  presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :problem_id,  presence: true, numericality: { only_integer: true, greater_than: 0 }

  private
    def invalidate_cache
      Team.invalidate_top_teams_score_progression
      Team.find(self.team_id).invalidate_score
      User.find(self.user_id).invalidate_score
    end
end
