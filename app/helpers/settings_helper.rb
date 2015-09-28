module SettingsHelper
	def competition_started?
		start_time = Time.parse(Setting.find_by(name: 'start_time').value)
		start_time < Time.zone.now
	end
	
	def competition_ended?
		end_time = Time.parse(Setting.find_by(name: 'end_time').value)
		Time.zone.now > end_time
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

end
