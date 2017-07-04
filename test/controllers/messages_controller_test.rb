require 'test_helper'

class MessagesControllerTest < ActionDispatch::IntegrationTest
  def setup
    @admin = users(:example_user)
    @non_admin = users(:archer)
    @message = messages(:test)
  end

  test "should redirect index when not logged in" do
    get chat_path
    assert_not flash.empty?
    assert_redirected_to login_url
  end

  test "should redirect new when not logged in" do
    post messages_path, params: { message: { message: @message.message } }
    assert_not flash.empty?
    assert_redirected_to login_url
  end

  test "should show messages index when logged in" do
    log_in_as(@non_admin)
    get chat_path
    assert flash.empty?
    assert_response :success
  end

  test "should create new message when user is logged in" do
    log_in_as(@non_admin)
    post messages_path, params: { message: { message: @message.message } }
    assert flash.empty?
    assert_redirected_to chat_url
  end

end
