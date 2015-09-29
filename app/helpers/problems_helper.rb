module ProblemsHelper
	def admin_user?
    logged_in? && current_user.admin?
	end

	def panel_collapsed(problem_view, problem)
		if problem_view && problem_view.id == problem.id
			'panel-collapse collapse in' 
		else
			'panel-collapse collapse'
		end
	end

	def add_id(string, object)
		"#{string}_#{object.id}"
	end

	def current_team
		if logged_in?
			Team.find(current_user.team_id)
		end
	end

	def get_hint(hint)
		hint.kind_of?(String) ? Hint.find(hint) : Hint.find(hint.hint_id)
	end

	def get_hints_for_problem(problem)
		admin_user? ? problem.hints_array : current_team.get_hints_requested(problem.id)
	end
end
