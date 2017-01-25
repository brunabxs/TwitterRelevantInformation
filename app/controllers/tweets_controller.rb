class TweetsController < ApplicationController
  TWITTER_COUNT = 30

  def list
    load_tweets_from_twitter(Rails.application.secrets.username, TWITTER_COUNT)  # TODO: handle 400 response when user prameter is not set
    @tweets = Tweet.joins(:user).includes(:user).
                    order('users.followers_count DESC').
                    order('retweets_count DESC').
                    order('likes_count DESC')
    @users = User.select('screen_name, followers_count, SUM(tweets.retweets_count) as `total_retweets_count`, SUM(tweets.likes_count) as `total_likes_count`').
                  joins(:tweets).
                  group([:screen_name, :followers_count]).
                  order('followers_count DESC').
                  order('total_retweets_count DESC').
                  order('total_likes_count DESC')
  end

  private
    def load_tweets_from_twitter(username, tweets_count)
      search_user = twitter_client.user(username)
      twitter_client.search("@#{username}", {result_type: "recent", count: tweets_count}).collect do |api_tweet|
        next if "#{api_tweet.in_reply_to_user_id}" == "#{search_user.id}"
        user = create_or_update_user(api_tweet)
        tweet = create_or_update_tweet(api_tweet, user)
      end
    end

    def twitter_client
      @twitter_client ||= Twitter::REST::Client.new do |config|
        config.consumer_key        = Rails.application.secrets.twitter_api_key
        config.consumer_secret     = Rails.application.secrets.twitter_api_secret
      end
    end

    def create_or_update_user(api_tweet)
      unless user = User.where(uid: "#{api_tweet.user.id}").first
        user = User.create do |user|
          user.uid = "#{api_tweet.user.id}"
          user.screen_name = "#{api_tweet.user.screen_name}"
          user.followers_count = api_tweet.user.followers_count
        end
      else
        user.screen_name = api_tweet.user.screen_name
        user.followers_count = api_tweet.user.followers_count
        user.save
      end
      user
    end

    def create_or_update_tweet(api_tweet, user)
      unless tweet = Tweet.where(uid: "#{api_tweet.id}").first
        tweet = Tweet.create do |tweet|
          tweet.uid = "#{api_tweet.id}"
          tweet.retweets_count = api_tweet.retweet_count
          tweet.likes_count = api_tweet.favorite_count
          tweet.creation_date  = "#{api_tweet.created_at}"
          tweet.text = api_tweet.text
          tweet.user_id = user.id
        end
      else
        tweet.retweets_count = api_tweet.retweet_count
        tweet.likes_count = api_tweet.favorite_count
        tweet.save
      end
      tweet
    end
end
