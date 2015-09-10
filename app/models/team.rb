class ValidateAtCapacity < ActiveModel::Validator
  def validate(record)
    if record.at_capacity?
      record.errors[] << 'Team has reached capcity'
    end
  end
end

class Team < ActiveRecord::Base
	include ActiveModel::Validations
	validates :name,  presence: true, length: { maximum: 50 },
										uniqueness: true
	validates :passphrase,  presence: true, length: { minimum: 6 }
	validates_with ValidateAtCapacity

	def add(user)
		if members_array.count < max_members_per_team
			save_members(members_array.push(user.id.to_s))
		else
			return false
		end
	end
	
	def remove(user)
		if self.members 
			save_members(members_array.reject! { |member| member == user.id.to_s })
		end
	end

	def at_capacity?
		if self.members 
			members_array.count >= max_members_per_team
		end
	end

	def members_array
		if !self.members # Lazy Instantiation
			Array.new
		else
			self.members.split(',')
		end
	end

	def save_members(members_array)
		update_attribute(:members, members_array.join(','))
	end

	def authenticate(passphrase)
		passphrase == self.passphrase
	end

	private
		def max_members_per_team
			Setting.find_by(name: 'max_members_per_team').value.to_i
		end
end
