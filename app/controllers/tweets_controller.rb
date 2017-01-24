class TweetsController < ApplicationController
  def twitter_client
    @twitter_client ||= Twitter::REST::Client.new do |config|
      config.consumer_key        = Rails.application.secrets.twitter_api_key
      config.consumer_secret     = Rails.application.secrets.twitter_api_secret
    end
  end

  def load(username, tweets_count)
    search_user = twitter_client.user(username)
    twitter_client.search("@#{username}", {result_type: "recent", count: tweets_count}).collect do |api_tweet|
      next if "#{api_tweet.in_reply_to_user_id}" == "#{search_user.id}"

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
    end
  end

  def list
    load(params.fetch(:username), params.fetch(:count, 1))  # TODO: handle 400 response when user prameter is not set
    @tweets = Tweet.joins(:user).includes(:user).
                    order('users.followers_count DESC').
                    order('retweets_count DESC').
                    order('likes_count DESC')
  end
end
