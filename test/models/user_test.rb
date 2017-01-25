require 'test_helper'

class UserTest < ActiveSupport::TestCase
  # Given The tweet '3030' that is a tweet with 100 retweets, 10 likes and from 'user1' with 300 followers
  #       The tweet '3031' that is a tweet with 100 retweets, 15 likes and from 'user1' with 300 followers
  #       The tweet '3032' that is a tweet with 100 retweets, 10 likes and from 'user2' with 350 followers
  #       The tweet '3033' that is a tweet with 200 retweets, 10 likes and from 'user2' with 350 followers
  #       The tweet '3034' that is a tweet with 10 retweets, 2 likes and from 'user3' with 400 followers
  # When finding the relevant users
  # Then the users must be in the following order 'user3', 'user2', 'user1'
  test "should retrieve users in relevant order" do
    # Arrange
    user1 = User.create(uid: '1010', screen_name: 'user1', followers_count: 300)
    user2 = User.create(uid: '1011',screen_name: 'user2', followers_count: 350)
    user3 = User.create(uid: '1012',screen_name: 'user3', followers_count: 400)
    Tweet.create(uid: '3030', retweets_count: 100, likes_count: 10, user_id: user1.id)
    Tweet.create(uid: '3031', retweets_count: 100, likes_count: 15, user_id: user1.id)
    Tweet.create(uid: '3032', retweets_count: 100, likes_count: 10, user_id: user2.id)
    Tweet.create(uid: '3033', retweets_count: 200, likes_count: 10, user_id: user2.id)
    Tweet.create(uid: '3034', retweets_count: 10, likes_count: 2, user_id: user3.id)

    # Act
    users = User.find_relevants

    # Assert
    assert_equal 'user3', users[0].screen_name
    assert_equal 'user2', users[1].screen_name
    assert_equal 'user1', users[2].screen_name
  end

  # Given The tweet '3030' that is a tweet with 100 retweets, 10 likes and from 'user1' with 300 followers
  #       The tweet '3031' that is a tweet with 100 retweets, 15 likes and from 'user1' with 300 followers
  # When finding the relevant users
  # Then the number of retweets and the number of likes must be aggregated
  test "should aggregate tweets information" do
    # Arrange
    user1 = User.create(uid: '1010', screen_name: 'user1', followers_count: 300)
    Tweet.create(uid: '3030', retweets_count: 100, likes_count: 10, user_id: user1.id)
    Tweet.create(uid: '3031', retweets_count: 100, likes_count: 15, user_id: user1.id)

    # Act
    users = User.find_relevants

    # Assert
    assert_equal 300, users[0].followers_count
    assert_equal 200, users[0].total_retweets_count
    assert_equal 25, users[0].total_likes_count
  end

  # Given no User with uid '1010'
  # When creating or updating users
  # Then an user with uid '1010' must be created
  test "should create user" do
    # Arrange
    # Act
    User.create_or_update('1010', 'user1', 10)

    # Assert
    assert_equal 1, User.where(uid: '1010').count
    user = User.where(uid: '1010').first
    assert_equal '1010', user.uid
    assert_equal 'user1', user.screen_name
    assert_equal 10, user.followers_count
  end

  # Given an User with uid '1010'
  # When creating or updating users
  # Then an user with uid '1010' must be updated
  test "should update user" do
    # Arrange
    User.create(uid: '1010', screen_name: 'user', followers_count: 10)

    # Act
    User.create_or_update('1010', 'user1', 20)

    # Assert
    assert_equal 1, User.where(uid: '1010').count
    user = User.where(uid: '1010').first
    assert_equal '1010', user.uid
    assert_equal 'user1', user.screen_name
    assert_equal 20, user.followers_count
  end
end
