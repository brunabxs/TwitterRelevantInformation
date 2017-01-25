require 'test_helper'
require 'webmock/test_unit'

class TweetsControllerTest < ActionDispatch::IntegrationTest
  # Given no Tweet with uid "250075927172759552"
  #       a Tweet with uid "123" mentioning user 'test_user' created by user 'user'
  #       a response for 'recent tweets mentioning user @test_user' request containing one tweet
  # When listing the tweets that mention user "@test_user"
  # Then a tweet with uid "250075927172759552" must be created for the existing user 'user'
  test "should create one tweet for existing user" do
    # Arrange
    WebMock.stub_request(:post, "https://api.twitter.com/oauth2/token").
      to_return(:status => 200, :body => "", :headers => {})

    WebMock.stub_request(:get, "https://api.twitter.com/1.1/users/show.json").
      with(query: {'screen_name': Rails.application.secrets.username}).
      to_return(:status => 200, :body => "{ \"id\": 999 }", :headers => {})

    WebMock.stub_request(:get, "https://api.twitter.com/1.1/search/tweets.json").
      with(query: {'q': '@'+Rails.application.secrets.username, 'count': TweetsController::TWITTER_COUNT, 'result_type': 'recent'}).
      to_return(body: file_fixture('twitter_api_response_body_one_tweet.json').read)

    # Act
    get tweets_list_url

    # Assert
    assert_response :success
    assert_equal 1, Tweet.where(uid: "250075927172759552").count
    tweet = Tweet.where(uid: "250075927172759552").first
    assert_equal 1, tweet.user_id
  end

  # Given no Tweet with uid "250075927172759552"
  #       no User with uid "2500"
  #       a response for 'recent tweets mentioning user @test_user' request containing one tweet
  # When listing the tweets that mention user "@test_user"
  # Then a user with uid "2500" must be created
  #      a tweet with uid "250075927172759552" must be created for created user
  test "should create one tweet for new user" do
    # Arrange
    WebMock.stub_request(:post, "https://api.twitter.com/oauth2/token").
      to_return(:status => 200, :body => "", :headers => {})

    WebMock.stub_request(:get, "https://api.twitter.com/1.1/users/show.json").
      with(query: {'screen_name': Rails.application.secrets.username}).
      to_return(:status => 200, :body => "{ \"id\": 999}", :headers => {})

    WebMock.stub_request(:get, "https://api.twitter.com/1.1/search/tweets.json").
      with(query: {'q': '@'+Rails.application.secrets.username, 'count': TweetsController::TWITTER_COUNT, 'result_type': 'recent'}).
      to_return(body: file_fixture('twitter_api_response_body_one_tweet_new_user.json').read)

    # Act
    get tweets_list_url

    # Assert
    assert_response :success
    assert_equal 1, Tweet.where(uid: "250075927172759552").count
    assert_equal 1, User.where(uid: "2500").count
    user = User.where(uid: "2500").first
    assert_equal "2500", user.uid
    assert_equal "user2", user.screen_name
    assert_equal 23, user.followers_count
  end

  # Given a Tweet with uid "123"
  #       a response for 'recent tweets mentioning user @test_user' request containing one tweet
  # When listing the tweets that mention user "@test_user"
  # Then the tweet must be updated (just the total retweets and total likes)
  test "should update the tweet" do
    # Arrange
    WebMock.stub_request(:post, "https://api.twitter.com/oauth2/token").
      to_return(:status => 200, :body => "", :headers => {})

    WebMock.stub_request(:get, "https://api.twitter.com/1.1/users/show.json").
      with(query: {'screen_name': Rails.application.secrets.username}).
      to_return(:status => 200, :body => "{ \"id\": 999 }", :headers => {})

    WebMock.stub_request(:get, "https://api.twitter.com/1.1/search/tweets.json").
      with(query: {'q': '@'+Rails.application.secrets.username, 'count': TweetsController::TWITTER_COUNT, 'result_type': 'recent'}).
      to_return(body: file_fixture('twitter_api_response_body_one_tweet_update_tweet.json').read)

    # Act
    get tweets_list_url

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
  #       a response for 'recent tweets mentioning user @test_user' request containing one tweet
  # When listing the tweets that mention user "@test_user"
  # Then the user must be updated (just the screen name and total followers)
  test "should update the user" do
    # Arrange
    WebMock.stub_request(:post, "https://api.twitter.com/oauth2/token").
      to_return(:status => 200, :body => "", :headers => {})

    WebMock.stub_request(:get, "https://api.twitter.com/1.1/users/show.json").
      with(query: {'screen_name': Rails.application.secrets.username}).
      to_return(:status => 200, :body => "{ \"id\": 999 }", :headers => {})

    WebMock.stub_request(:get, "https://api.twitter.com/1.1/search/tweets.json").
      with(query: {'q': '@'+Rails.application.secrets.username, 'count': TweetsController::TWITTER_COUNT, 'result_type': 'recent'}).
      to_return(body: file_fixture('twitter_api_response_body_one_tweet_update_user.json').read)

    # Act
    get tweets_list_url

    # Assert
    assert_response :success
    assert_equal 1, User.where(uid: "1").count
    user = User.where(uid: "1").first
    assert_equal "1", user.uid
    assert_equal "user2", user.screen_name
    assert_equal 23, user.followers_count
  end

  # Given a response for 'recent tweets mentioning user @test_user' request containing three tweets:
  #       The tweet "3030" that is a reply to "@test_user" and
  #       The tweet "3031" that is a reply to "@another_user" and
  #       The tweet "3032" that is not a reply
  # When listing the tweets that mention user "@test_user"
  # Then only tweets with uid "3031" and "3032" must be created
  test "should create one tweet if not a reply to given username" do
    # Arrange   
    WebMock.stub_request(:post, "https://api.twitter.com/oauth2/token").
      to_return(:status => 200, :body => "", :headers => {})

    WebMock.stub_request(:get, "https://api.twitter.com/1.1/users/show.json").
      with(query: {'screen_name': Rails.application.secrets.username}).
      to_return(:status => 200, :body => "{ \"id\": 999 }", :headers => {})

    WebMock.stub_request(:get, "https://api.twitter.com/1.1/search/tweets.json").
      with(query: {'q': '@'+Rails.application.secrets.username, 'count': TweetsController::TWITTER_COUNT, 'result_type': 'recent'}).
      to_return(body: file_fixture('twitter_api_response_body_reply_tweets.json').read)

    # Act
    get tweets_list_url

    # Assert
    assert_response :success
    assert_equal 0, Tweet.where(uid: "3030").count
    assert_equal 1, Tweet.where(uid: "3031").count
    assert_equal 1, Tweet.where(uid: "3032").count
  end

  # Given a response for 'recent tweets mentioning user @test_user' request containing some tweets:
  #       The tweet "3030" that is a tweet with 100 retweets, 10 likes and from a user with 300 followers
  #       The tweet "3031" that is a tweet with 100 retweets, 15 likes and from a user with 300 followers
  #       The tweet "3032" that is a tweet with 100 retweets, 10 likes and from a user with 350 followers
  #       The tweet "3033" that is a tweet with 200 retweets, 10 likes and from a user with 350 followers
  #       The tweet "3034" that is a tweet with 10 retweets, 2 likes and from a user with 400 followers
  # When listing the tweets that mention user "@test_user"
  # Then the tweets must be in the following order of uid "3034", "3033", "3032", "3031" and "3030"
  test "should retrieve tweets in a certain order" do
    # Arrange
    WebMock.stub_request(:post, "https://api.twitter.com/oauth2/token").
      to_return(:status => 200, :body => "", :headers => {})

    WebMock.stub_request(:get, "https://api.twitter.com/1.1/users/show.json").
      with(query: {'screen_name': Rails.application.secrets.username}).
      to_return(:status => 200, :body => "{ \"id\": 999 }", :headers => {})

    WebMock.stub_request(:get, "https://api.twitter.com/1.1/search/tweets.json").
      with(query: {'q': '@'+Rails.application.secrets.username, 'count': TweetsController::TWITTER_COUNT, 'result_type': 'recent'}).
      to_return(body: file_fixture('twitter_api_response_body_sort.json').read)

    # Act
    get tweets_list_url

    # Assert
    assert_response :success
    tweets = assigns(:tweets)
    assert_equal "3034", tweets[0].uid
    assert_equal "3033", tweets[1].uid
    assert_equal "3032", tweets[2].uid
    assert_equal "3031", tweets[3].uid
    assert_equal "3030", tweets[4].uid
  end

  # Given a response for 'recent tweets mentioning user @test_user' request containing some tweets:
  #       The tweet "3030" that is a tweet with 100 retweets, 10 likes and from 'user1' with 300 followers
  #       The tweet "3031" that is a tweet with 100 retweets, 15 likes and from 'user1' with 300 followers
  #       The tweet "3032" that is a tweet with 100 retweets, 10 likes and from 'user2' with 350 followers
  #       The tweet "3033" that is a tweet with 200 retweets, 10 likes and from 'user2' with 350 followers
  #       The tweet "3034" that is a tweet with 10 retweets, 2 likes and from 'user3' with 400 followers
  # When listing the users that mention user "@test_user"
  # Then the users must be in the following order "user3", "user2", "user1"
  test "should retrieve users in a certain order" do
    # Arrange
    WebMock.stub_request(:post, "https://api.twitter.com/oauth2/token").
      to_return(:status => 200, :body => "", :headers => {})

    WebMock.stub_request(:get, "https://api.twitter.com/1.1/users/show.json").
      with(query: {'screen_name': Rails.application.secrets.username}).
      to_return(:status => 200, :body => "{ \"id\": 999 }", :headers => {})

    WebMock.stub_request(:get, "https://api.twitter.com/1.1/search/tweets.json").
      with(query: {'q': '@'+Rails.application.secrets.username, 'count': TweetsController::TWITTER_COUNT, 'result_type': 'recent'}).
      to_return(body: file_fixture('twitter_api_response_body_sort.json').read)

    # Act
    get tweets_list_url

    # Assert
    assert_response :success
    users = assigns(:users)
    assert_equal "user3", users[0].screen_name
    assert_equal 400, users[0].followers_count
    assert_equal 10, users[0].total_retweets_count
    assert_equal 2, users[0].total_likes_count
    assert_equal "user2", users[1].screen_name
    assert_equal 350, users[1].followers_count
    assert_equal 300, users[1].total_retweets_count
    assert_equal 20, users[1].total_likes_count
    assert_equal "user1", users[2].screen_name
    assert_equal 300, users[2].followers_count
    assert_equal 200, users[2].total_retweets_count
    assert_equal 25, users[2].total_likes_count
  end
end
