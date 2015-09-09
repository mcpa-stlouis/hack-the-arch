module ProblemsHelper
	def admin_user?
    logged_in? && current_user.admin?
	end
end
