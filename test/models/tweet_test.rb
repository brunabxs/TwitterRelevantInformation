require 'test_helper'

class TweetTest < ActiveSupport::TestCase
  # Given The tweet '3030' that is a tweet with 100 retweets, 10 likes and from 'user1' with 300 followers
  #       The tweet '3031' that is a tweet with 100 retweets, 15 likes and from 'user1' with 300 followers
  #       The tweet '3032' that is a tweet with 100 retweets, 10 likes and from 'user2' with 350 followers
  #       The tweet '3033' that is a tweet with 200 retweets, 10 likes and from 'user2' with 350 followers
  #       The tweet '3034' that is a tweet with 10 retweets, 2 likes and from 'user3' with 400 followers
  # When finding the relevant tweets
  # Then the tweets must be in the following order of uid '3034', '3033', '3032', '3031' and '3030'
  test "should retrieve tweets in relevant order" do
    # Arrange
    user1 = User.create(uid: '1010', screen_name: 'user1', followers_count: 300)
    user2 = User.create(uid: '1011',screen_name: 'user2', followers_count: 350)
    user3 = User.create(uid: '1012',screen_name: 'user3', followers_count: 400)
    tweet1 = Tweet.create(uid: '3030', retweets_count: 100, likes_count: 10, user_id: user1.id)
    tweet2 = Tweet.create(uid: '3031', retweets_count: 100, likes_count: 15, user_id: user1.id)
    tweet3 = Tweet.create(uid: '3032', retweets_count: 100, likes_count: 10, user_id: user2.id)
    tweet4 = Tweet.create(uid: '3033', retweets_count: 200, likes_count: 10, user_id: user2.id)
    tweet5 = Tweet.create(uid: '3034', retweets_count: 10, likes_count: 2, user_id: user3.id)

    # Act
    tweets = Tweet.find_relevants

    # Assert
    assert_equal tweet5.uid, tweets[0].uid
    assert_equal tweet4.uid, tweets[1].uid
    assert_equal tweet3.uid, tweets[2].uid
    assert_equal tweet2.uid, tweets[3].uid
    assert_equal tweet1.uid, tweets[4].uid
  end

  # Given no Tweet with uid '3030' for user '1010'
  # When creating or updating tweets
  # Then a tweet with uid '3030' must be created for user '1010'
  test "should create tweet" do
    # Arrange
    user = User.create(uid: '1010')

    # Act
    Tweet.create_or_update('3030', 10, 11, '', 'Text', user.id)

    # Assert
    assert_equal 1, Tweet.where(uid: '3030').count
    tweet = Tweet.where(uid: '3030').first
    assert_equal '3030', tweet.uid
    assert_equal 10, tweet.retweets_count
    assert_equal 11, tweet.likes_count
    assert_nil tweet.creation_date
    assert_equal 'Text', tweet.text
    assert_equal '1010', tweet.user.uid
  end

  # Given a Tweet with uid '3030' for user '1010'
  # When creating or updating tweets
  # Then a tweet with uid '3030' must be updated
  test "should update tweet" do
    # Arrange
    user1 = User.create(uid: '1010')
    Tweet.create_or_update('3030', 10, 11, '', 'Text', user1.id)
    user2 = User.create(uid: '1011')

    # Act
    Tweet.create_or_update('3030', 20, 21, '', 'Text.new', user2.id)

    # Assert
    assert_equal 1, Tweet.where(uid: '3030').count
    tweet = Tweet.where(uid: '3030').first
    assert_equal '3030', tweet.uid
    assert_equal 20, tweet.retweets_count
    assert_equal 21, tweet.likes_count
    assert_nil tweet.creation_date
    assert_equal 'Text.new', tweet.text
    assert_equal '1011', tweet.user.uid
  end
end
