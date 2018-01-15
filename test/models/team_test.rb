require 'test_helper'

class TeamTest < ActiveSupport::TestCase
  def setup
    @team = teams(:opponent_team)
    @user1 = users(:archer)
    @user2 = users(:malory)
    @user3 = users(:cyril)
    @problem = problems(:example_problem)
  end

  test "shouldn't allow more than 2 users to be added to team" do
    @user1.leave_team()
    @user1.join_team(@team)
    assert_not @team.valid?
  end

  test "should get cached values on second get" do
    Submission.create(team_id:  @team.id,
                      user_id: @user2.id,
                      problem_id: @problem.id,
                      submission: @problem.solution,
                      correct: true,
                      points: @problem.points)
    assert_not Cache.find_by(key: 'top_teams_score_progression')
    Team.get_top_teams_score_progression(5)
    assert Cache.find_by(key: 'top_teams_score_progression').cache_valid
    Team.get_top_teams_score_progression(5)
  end


end
