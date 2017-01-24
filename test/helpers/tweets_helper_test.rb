require 'test_helper'

class TweetsHelperTest < ActionView::TestCase
    # Given a tweet
    # When the link to this tweet is requested
    # Then the correct twitter link must me given
    test "should return the tweet link" do
        # Arrange
        tweet = tweets(:one)
        expected = %{<a target="_blank" href="http://www.twitter.com/#{tweet.user.screen_name}/status/#{tweet.uid}">#{tweet.text}</a>}

        # Act
        actual = link_to_twitter_tweet(tweet)

        # Assert
        assert_dom_equal expected, actual
    end

    # Given a twitter user
    # When the link to this user is requested
    # Then the correct twitter link must me given
    test "should return the user link" do
        # Arrange
        user = users(:one)
        expected = %{<a target="_blank" href="http://www.twitter.com/#{user.screen_name}">#{user.screen_name}</a>}

        # Act
        actual = link_to_twitter_user(user)

        # Assert
        assert_dom_equal expected, actual
    end
end