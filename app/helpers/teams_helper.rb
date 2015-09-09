module TeamsHelper
	def is_member?(user, team)
		user.team_id == team.id
	end
end
