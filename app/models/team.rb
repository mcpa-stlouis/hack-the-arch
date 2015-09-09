class Team < ActiveRecord::Base
	validates :name,  presence: true, length: { maximum: 50 },
										uniqueness: true
	validates :passphrase,  presence: true, length: { maximum: 50 }

	def add(user)
		if !self.members # Lazy Instantiation
			mem_array = Array.new
		else
			mem_array = self.members.split(',')
		end

		if mem_array.count < max_members_per_team
			mem_array.push(user.id.to_s)
			update_attribute(:members, mem_array.join(','))
		else
			return false
		end
	end

	
	def remove(user)
		if self.members 
			mem_array = self.members.split(',')
			mem_array.reject! { |member| member == user.id.to_s }
			update_attribute(:members, mem_array.join(','))
		end
	end

	def at_capacity?
		if self.members 
			mem_array = self.members.split(',')
			mem_array.count >= max_members_per_team
		end
	end

	def authenticate(passphrase)
		passphrase == self.passphrase
	end

	private
		def max_members_per_team
			Setting.find_by(name: 'max_members_per_team').value.to_i
		end
end
