class User < ActiveRecord::Base
	include SettingsHelper
	attr_accessor :remember_token, :activation_token, :reset_token
  before_save   :downcase_email
	belongs_to :team
	has_many :submissions, dependent: :destroy, inverse_of: :user
	has_many :hint_requests, dependent: :destroy, inverse_of: :user
	validates :fname,  presence: true, length: { maximum: 50 }
	validates :lname,  presence: true, length: { maximum: 50 }
	validates :username, presence: true, length: { maximum: 128 }, 
											 uniqueness: {case_sensitive: true}
	VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
	validates :email, presence: true, length: { maximum: 255 }, 
										format: { with: VALID_EMAIL_REGEX },
										uniqueness: { case_sensitive: false }
	has_secure_password
	validates :password, presence: true, length: { minimum:6 }, allow_nil: true

	def User.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                  BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end

	def User.new_token
		SecureRandom.urlsafe_base64
	end

	def is_member?(team)
		self.team_id == team.id
	end

	def leave_team
		update_attribute(:team_id, nil)
	end

	def join_team(team)
		update_attribute(:team_id, team.id)
	end

	def remember
		self.remember_token = User.new_token
		update_attribute :remember_digest, User.digest(remember_token)
	end

	def authenticated?(attribute, token)
    digest = send("#{attribute}_digest")
    return false if digest.nil?
    BCrypt::Password.new(digest).is_password?(token)
  end

	def forget
		update_attribute :remember_digest, nil
	end

	def activate
    update_attribute(:activated,    true)
    update_attribute(:activated_at, Time.zone.now)
  end

  # Creates and assigns the activation token and digest.
  def create_activation_digest
    self.activation_token  = User.new_token
    update_attribute(:activation_digest,  User.digest(activation_token))
  end

	def send_activation_email
    UserMailer.account_activation(self).deliver_now
  end

	def create_reset_digest
    self.reset_token = User.new_token
    update_attribute(:reset_digest,  User.digest(reset_token))
    update_attribute(:reset_sent_at, Time.zone.now)
  end

	def send_password_reset_email
    UserMailer.password_reset(self).deliver_now
  end
	
	def password_reset_expired?
    reset_sent_at < 2.hours.ago
  end

	def get_score
		cache = Cache.find_by(key: 'user_'+self.id.to_s+'_score')
		if cache && cache.cache_valid
			cache.value.to_i
		else
			if subtract_hint_points_before_solve?
				score = Submission.where(user_id: self.id).sum(:points) - 
				HintRequest.where(user_id: self.id).sum(:points)
			else
				score = 0
				for submission in Submission.where(user_id: self.id)
					if submission.correct
						score = score + submission.points
						for hint in HintRequest.where(user_id: self.id, problem_id: submission.problem_id)
							score = score - hint.points
						end
					end
				end
			end

			# Update cache
			if cache 
				cache.update(score)
			else
				Cache.create(key: 'user_'+self.id.to_s+'_score', value: score, cache_valid: true)
			end
			score
		end
	end

	def invalidate_score
		cache = Cache.find_by(key: 'user_'+self.id.to_s+'_score')
		if cache
			cache.invalidate
		end
	end

	def get_accuracy_data
		result = Array.new

		result.push(['Correct', self.submissions.where(correct: true).count])
		result.push(['Incorrect', self.submissions.where.not(correct: true).count])

		result
	end

	def get_category_data
		result = Array.new
		@intermediate_result = Hash.new
		@categories = Problem.select(:category).distinct
		@subs = self.submissions.where(correct: true)
		@category = ""
		@count = 0

		for @category in @categories
			@intermediate_result[@category.category] = 0
		end

		for @sub in @subs
			@intermediate_result[@sub.problem.category] += 1
		end

		@intermediate_result.each do |key, value|
			result.push([key, value])
		end
		result

	end

	private

    # Converts email to all lower-case.
    def downcase_email
      self.email = email.downcase
    end

end
