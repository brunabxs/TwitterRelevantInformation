module TweetsHelper
    def link_to_twitter_tweet(tweet)
        link_to tweet.text, "http://www.twitter.com/#{tweet.user.screen_name}/status/#{tweet.uid}", :target => "_blank"
    end

    def link_to_twitter_user(user)
        link_to user.screen_name, "http://www.twitter.com/#{user.screen_name}", :target => "_blank"
    end
end
