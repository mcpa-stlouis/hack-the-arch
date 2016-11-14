class SubmissionBroadcastJob < ApplicationJob
  queue_as :default

  def perform(submission)
    ActionCable.server.broadcast 'submission_channel', submission: render_submission(submission)
  end

  private
    def render_submission(submission)
      ApplicationController.renderer.render(partial: 'submissions/submission_feed',
                                             locals: { submission: submission })
    end
    
end
