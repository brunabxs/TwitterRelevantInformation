class Tweet < ApplicationRecord
    belongs_to :user

    def self.find_relevants
        Tweet.joins(:user).includes(:user).
              order('users.followers_count DESC').
              order('retweets_count DESC').
              order('likes_count DESC')
    end

    def self.create_or_update(uid, retweets_count, likes_count, creation_date, text, user_id)
        tweet = Tweet.find_or_initialize_by(uid: uid)
        tweet.retweets_count = retweets_count
        tweet.likes_count = likes_count
        tweet.creation_date = creation_date
        tweet.text = text
        tweet.user_id = user_id
        tweet.save
        tweet
    end
end
