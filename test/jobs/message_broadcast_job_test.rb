require 'test_helper'

class MessageBroadcastJobTest < ActiveJob::TestCase
  def setup
    @message = messages(:test)
  end

  test 'should send message' do
    MessageBroadcastJob.perform_now(@message)
  end
end
