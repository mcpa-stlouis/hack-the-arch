module SettingsHelper
	def competition_started?
		start_time = DateTime.strptime(Setting.find_by(name: 'start_time').value, '%m/%d/%Y %I:%M %p')
		DateTime.current.to_i > start_time.to_i
	end
	
	def competition_ended?
		end_time = DateTime.strptime(Setting.find_by(name: 'end_time').value, '%m/%d/%Y %I:%M %p')
		DateTime.current.to_i > end_time.to_i
	end

	def competition_active?
		competition_started? && !competition_ended?
	end

	def competition_name
		Setting.find_by(name: 'competition_name').value
	end

	def subtract_hint_points_before_solve?
		(Setting.find_by(name: 'subtract_hint_points_before_solve').value == "0") ? false : true
	end

	def scoreboard_on?
		(Setting.find_by(name: 'scoreboard_on').value == "0") ? false : true
	end

	def send_activation_emails?
		(Setting.find_by(name: 'send_activation_emails').value == "0") ? false : true
	end

	def view_other_profiles?
		(Setting.find_by(name: 'view_other_profiles').value == "0") ? false : true
	end

	def use_handicap?
		(Setting.find_by(name: 'use_bracket_handicaps').value == "0") ? false : true
	end

	def require_payment?
		(Setting.find_by(name: 'require_payment').value == "0") ? false : true
	end

	def registration_active?
		(Setting.find_by(name: 'registration_active').value == "0") ? false : true
	end

	def entry_cost
		Setting.find_by(name: 'entry_cost').value
	end

	def fifty_percent_off
		Setting.find_by(name: 'fifty_percent_off').value
	end

	def one_hundred_percent_off
		Setting.find_by(name: 'one_hundred_percent_off').value
	end

	# returns int value of setting if it's between 0 and 2 ^ 16, otherwise 0
	# 0 = no limit on submissions
	def max_submissions_per_team
		(value = Setting.find_by(name: 'max_submissions_per_team').value.to_i).between?(0,2**16) ? value : 0
	end

end
