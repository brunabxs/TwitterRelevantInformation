require 'test_helper'
require 'webmock/test_unit'

class TweetsControllerTest < ActionDispatch::IntegrationTest
  # Given a response for 'recent tweets mentioning user @test_user' request containing three tweets:
  #       The tweet '3030' that is a reply to '@test_user' and
  #       The tweet '3031' that is a reply to '@another_user' and
  #       The tweet '3032' that is not a reply
  # When listing the tweets that mention user '@test_user'
  # Then only tweets with uid '3031' and '3032' must be created
  test "should create tweet if it is not a reply to given username" do
    # Arrange
    username = Rails.application.secrets.username
    count = TweetsController::TWITTER_COUNT
    
    WebMock.stub_request(:post, 'https://api.twitter.com/oauth2/token').
      to_return(:status => 200, :body => '', :headers => {})

    WebMock.stub_request(:get, 'https://api.twitter.com/1.1/users/show.json').
      with(query: {'screen_name': username}).
      to_return(:status => 200, :body => '{"id": 999}', :headers => {})

    WebMock.stub_request(:get, 'https://api.twitter.com/1.1/search/tweets.json').
      with(query: {'q': "@#{username}", 'count': count, 'result_type': 'recent'}).
      to_return(body: file_fixture('twitter_api_response_body_reply_tweets.json').read)

    # Act
    get tweets_list_url

    # Assert
    assert_response :success
    assert_equal 0, Tweet.where(uid: '3030').count
    assert_equal 1, Tweet.where(uid: '3031').count
    assert_equal 1, Tweet.where(uid: '3032').count
  end
end
