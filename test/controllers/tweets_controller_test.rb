require 'test_helper'
require 'webmock/test_unit'

class TweetsControllerTest < ActionDispatch::IntegrationTest
  # Given no Tweet with uid "250075927172759552"
  #       a Tweet with uid "123" for user 'test_user'
  #       a response for 'recent tweets of user @test_user' request containing one tweet
  # When listing the tweets of user "@test_user"
  # Then a tweet with uid "250075927172759552" must be created for the existing user
  test "should create one tweet for existing user" do
    # Arrange
    WebMock.stub_request(:post, "https://api.twitter.com/oauth2/token").
      to_return(:status => 200, :body => "", :headers => {})

    WebMock.stub_request(:get, "https://api.twitter.com/1.1/users/show.json").
      with(query: {'screen_name': 'test_user'}).
      to_return(:status => 200, :body => "{ \"id\": 1 }", :headers => {})

    WebMock.stub_request(:get, "https://api.twitter.com/1.1/search/tweets.json").
      with(query: {'q': '@test_user', 'count': 1, 'result_type': 'recent'}).
      to_return(body: file_fixture('twitter_api_response_body_one_tweet.json').read)

    # Act
    get tweets_list_url, params: {username: "test_user"}

    # Assert
    assert_response :success
    assert_equal 1, Tweet.where(uid: "250075927172759552").count
    tweet = Tweet.where(uid: "250075927172759552").first
    assert_equal 1, tweet.user_id
  end

  # Given no Tweet with uid "250075927172759552"
  #       no User with uid "2500"
  #       a response for 'recent tweets of user @test_user2' request containing one tweet
  # When listing the tweets of user "@test_user2"
  # Then a user with uid "2500" must be created
  #      a tweet with uid "250075927172759552" must be created for created user
  test "should create one tweet for new user" do
    # Arrange
    WebMock.stub_request(:post, "https://api.twitter.com/oauth2/token").
      to_return(:status => 200, :body => "", :headers => {})

    WebMock.stub_request(:get, "https://api.twitter.com/1.1/users/show.json").
      with(query: {'screen_name': 'test_user2'}).
      to_return(:status => 200, :body => "{ \"id\": 2500}", :headers => {})

    WebMock.stub_request(:get, "https://api.twitter.com/1.1/search/tweets.json").
      with(query: {'q': '@test_user2', 'count': 1, 'result_type': 'recent'}).
      to_return(body: file_fixture('twitter_api_response_body_one_tweet_new_user.json').read)

    # Act
    get tweets_list_url, params: {username: "test_user2"}

    # Assert
    assert_response :success
    assert_equal 1, Tweet.where(uid: "250075927172759552").count
    assert_equal 1, User.where(uid: "2500").count
    user = User.where(uid: "2500").first
    assert_equal "2500", user.uid
    assert_equal "test_user2", user.screen_name
    assert_equal 23, user.followers_count
  end

  # Given a Tweet with uid "123"
  #       a response for 'recent tweets of user @test_user' request containing one tweet
  # When listing the tweets of user "@test_user"
  # Then the tweet must be updated (just the total retweets and total likes)
  test "should update the tweet" do
    # Arrange
    WebMock.stub_request(:post, "https://api.twitter.com/oauth2/token").
      to_return(:status => 200, :body => "", :headers => {})

    WebMock.stub_request(:get, "https://api.twitter.com/1.1/users/show.json").
      with(query: {'screen_name': 'test_user'}).
      to_return(:status => 200, :body => "{ \"id\": 1 }", :headers => {})

    WebMock.stub_request(:get, "https://api.twitter.com/1.1/search/tweets.json").
      with(query: {'q': '@test_user', 'count': 1, 'result_type': 'recent'}).
      to_return(body: file_fixture('twitter_api_response_body_one_tweet_update_tweet.json').read)

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

  # Given an User with uid "123"
  #       a response for 'recent tweets of user @test_user_updated' request containing one tweet
  # When listing the tweets of user "@test_user_updated"
  # Then the user must be updated (just the screen name and total followers)
  test "should update the user" do
    # Arrange
    WebMock.stub_request(:post, "https://api.twitter.com/oauth2/token").
      to_return(:status => 200, :body => "", :headers => {})

    WebMock.stub_request(:get, "https://api.twitter.com/1.1/users/show.json").
      with(query: {'screen_name': 'test_user_updated'}).
      to_return(:status => 200, :body => "{ \"id\": 1 }", :headers => {})

    WebMock.stub_request(:get, "https://api.twitter.com/1.1/search/tweets.json").
      with(query: {'q': '@test_user_updated', 'count': 1, 'result_type': 'recent'}).
      to_return(body: file_fixture('twitter_api_response_body_one_tweet_update_user.json').read)

    # Act
    get tweets_list_url, params: {username: "test_user_updated"}

    # Assert
    assert_response :success
    assert_equal 1, User.where(uid: "1").count
    user = User.where(uid: "1").first
    assert_equal "1", user.uid
    assert_equal "test_user_updated", user.screen_name
    assert_equal 23, user.followers_count
  end

  # Given a response for 'recent tweets of user @test_user' request containing two tweets:
  #       The tweet "3030" that is a reply to "@test_user" and
  #       The tweet "3031" that is a reply to "@another_user" and
  #       The tweet "3032" that is not a reply
  # When listing the tweets of user "@test_user"
  # Then only tweets with uid "3031" and "3032" must be created
  test "should create one tweet if not a reply to given username" do
    # Arrange   
    WebMock.stub_request(:post, "https://api.twitter.com/oauth2/token").
      to_return(:status => 200, :body => "", :headers => {})

    WebMock.stub_request(:get, "https://api.twitter.com/1.1/users/show.json").
      with(query: {'screen_name': 'test_user'}).
      to_return(:status => 200, :body => "{ \"id\": 1 }", :headers => {})

    WebMock.stub_request(:get, "https://api.twitter.com/1.1/search/tweets.json").
      with(query: {'q': '@test_user', 'count': 10, 'result_type': 'recent'}).
      to_return(body: file_fixture('twitter_api_response_body_reply_tweets.json').read)

    # Act
    get tweets_list_url, params: {username: "test_user", count: 10}

    # Assert
    assert_response :success
    assert_equal 0, Tweet.where(uid: "3030").count
    assert_equal 1, Tweet.where(uid: "3031").count
    assert_equal 1, Tweet.where(uid: "3032").count
  end


  # Given a response for '10 recent tweets of user @test_user' request
  # When listing the 10 tweets of user "@test_user"
  # Then the response must me 200
  test "should consider username and count request parameters" do
    # Arrange
    WebMock.stub_request(:post, "https://api.twitter.com/oauth2/token").
      to_return(:status => 200, :body => "", :headers => {})

    WebMock.stub_request(:get, "https://api.twitter.com/1.1/users/show.json").
      with(query: {'screen_name': 'test_user'}).
      to_return(:status => 200, :body => "{ \"id\": 1 }", :headers => {})

    WebMock.stub_request(:get, "https://api.twitter.com/1.1/search/tweets.json").
      with(query: {'q': '@test_user', 'count': 10, 'result_type': 'recent'}).
      to_return(body: file_fixture('twitter_api_response_body_one_tweet.json').read)

    # Act
    get tweets_list_url, params: {username: "test_user", count: 10}

    # Assert
    assert_response :success
  end
end
