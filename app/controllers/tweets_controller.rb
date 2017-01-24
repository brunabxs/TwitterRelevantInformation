class TweetsController < ApplicationController
  def list
    client = Twitter::REST::Client.new do |config|
      config.consumer_key        = Rails.application.secrets.twitter_api_key
      config.consumer_secret     = Rails.application.secrets.twitter_api_secret
    end
    
    client.search("to:justinbieber marry me", result_type: "recent", count: 3).collect do |tweet|
      puts "#{tweet.user.screen_name}: #{tweet.text}"
    end
  end
end
