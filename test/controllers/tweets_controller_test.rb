require 'test_helper'
require 'webmock/test_unit'

class TweetsControllerTest < ActionDispatch::IntegrationTest
  # Given no Tweet with uid "250075927172759552"
  #       a response for 'recent tweets of user @test_user' request containing one tweet
  # When listing the tweets of user "@test_user"
  # Then a tweet with uid "250075927172759552" must be created
  test "should create one tweet" do
    # Arrange
    WebMock.stub_request(:post, "https://api.twitter.com/oauth2/token").
      to_return(:status => 200, :body => "", :headers => {})

    WebMock.stub_request(:get, "https://api.twitter.com/1.1/search/tweets.json").
      with(query: {'q': '@test_user', 'count': 1, 'result_type': 'recent'}).
      to_return(body: file_fixture('twitter_api_response_body_one_tweet.json').read)

    # Act
    get tweets_list_url, params: {username: "test_user"}

    # Assert
    assert_response :success
    assert_equal 1, Tweet.where(uid: "250075927172759552").count
  end

  # Given a Tweet with uid "123"
  #       a response for 'recent tweets of user @test_user' request containing one tweet
  # When listing the tweets of user "@test_user"
  # Then the tweet must be updated (just the total retweets and total likes)
  test "should update the tweet" do
    # Arrange
    WebMock.stub_request(:post, "https://api.twitter.com/oauth2/token").
      to_return(:status => 200, :body => "", :headers => {})

    WebMock.stub_request(:get, "https://api.twitter.com/1.1/search/tweets.json").
      with(query: {'q': '@test_user', 'count': 1, 'result_type': 'recent'}).
      to_return(body: file_fixture('twitter_api_response_body_one_tweet_update.json').read)

    # Act
    get tweets_list_url, params: {username: "test_user"}

    # Assert
    assert_response :success
    assert_equal 1, Tweet.where(uid: "123").count
    tweet = Tweet.where(uid: "123").first
    assert_equal "123", tweet.uid
    assert_equal 10, tweet.retweets_count
    assert_equal 11, tweet.likes_count
    assert_equal "Text", tweet.text
  end

  # Given a response for '10 recent tweets of user @test_user' request
  # When listing the 10 tweets of user "@test_user"
  # Then the response must me 200
  test "should consider username and count request parameters" do
    # Arrange
    WebMock.stub_request(:post, "https://api.twitter.com/oauth2/token").
      to_return(:status => 200, :body => "", :headers => {})

    WebMock.stub_request(:get, "https://api.twitter.com/1.1/search/tweets.json").
      with(query: {'q': '@test_user', 'count': 10, 'result_type': 'recent'}).
      to_return(body: file_fixture('twitter_api_response_body_one_tweet.json').read)

    # Act
    get tweets_list_url, params: {username: "test_user", count: 10}

    # Assert
    assert_response :success
  end
end
