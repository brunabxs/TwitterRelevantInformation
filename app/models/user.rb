class User < ApplicationRecord
    has_many :tweets

    def self.find_relevants
        User.select('screen_name, followers_count, SUM(tweets.retweets_count) as `total_retweets_count`, SUM(tweets.likes_count) as `total_likes_count`').
             joins(:tweets).
             group([:screen_name, :followers_count]).
             order('followers_count DESC').
             order('total_retweets_count DESC').
             order('total_likes_count DESC')
    end 

    def self.create_or_update(uid, screen_name, followers_count)
        user = User.find_or_initialize_by(uid: uid)
        user.screen_name = screen_name
        user.followers_count = followers_count
        user.save
        user
    end
end
