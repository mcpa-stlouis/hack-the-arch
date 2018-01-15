class Message < ApplicationRecord
  unless ENV.fetch("RAILS_ENV") == "test" 
    after_create_commit { MessageBroadcastJob.perform_later self }
  end

  belongs_to :user
  validates :message, presence: true, length: { maximum: 2048 }
  validates :priority, inclusion: {in: ['success', 'danger', 'warning', 'info'] }
  validates :priority, exclusion: {in: [nil] }
  validates :user_id,  presence: true, numericality: { only_integer: true, greater_than: 0 }
end
