class TweetsController < ApplicationController
  TWITTER_COUNT = 30

  def list
    load_tweets_from_twitter(Rails.application.secrets.username, TWITTER_COUNT)
    @tweets = Tweet.find_relevants
    @users = User.find_relevants
  end

  private
    def load_tweets_from_twitter(username, tweets_count)
      search_user = twitter_client.user(username)
      twitter_client.search("@#{username}", {result_type: "recent", count: tweets_count}).collect do |api_tweet|
        next if "#{api_tweet.in_reply_to_user_id}" == "#{search_user.id}"
        user = User.create_or_update("#{api_tweet.user.id}",
                                     "#{api_tweet.user.screen_name}",
                                     api_tweet.user.followers_count)

        Tweet.create_or_update("#{api_tweet.id}", api_tweet.retweet_count,
                               api_tweet.favorite_count, "#{api_tweet.created_at}",
                               api_tweet.text, user.id)
      end
    end

    def twitter_client
      @twitter_client ||= Twitter::REST::Client.new do |config|
        config.consumer_key        = Rails.application.secrets.twitter_api_key
        config.consumer_secret     = Rails.application.secrets.twitter_api_secret
      end
    end
end
