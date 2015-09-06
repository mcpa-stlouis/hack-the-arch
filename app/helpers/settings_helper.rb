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
end
