# Twitter Relevant Information

[![Build Status](https://travis-ci.org/brunabxs/TwitterRelevantInformation.svg?branch=master)](https://travis-ci.org/brunabxs/TwitterRelevantInformation)

Can you tell which are the most relevant tweets for a given user? And the most relevant users?
A relevant tweet is a tweet that mentions a certain user. Also, it cannot be a reply to the user's tweet.

This project gathers and lists the most relevant tweets and users for a certain user.
They are sorted by importance:
  1. Tweets of users that have more followers
  2. Tweets that have more retweets
  3. Tweets that have more likes

## What did we use?
- [Ruby (v2.3.3)](http://www.ruby-lang.org/en/)
- [Ruby on Rails (v5.0.1)](http://rubyonrails.org/)
- [Twitter API (v6.1.0)](https://github.com/sferik/twitter)
- [Travis CS](https://travis-ci.org)

See more on Gemfile.

## Development (Windows 10)
### Running the application
- Go to the project's root directory.
- Setup the environment variables. Their values must be set with Twitter API Key and Twitter API Secret. If you do not want to set those variables, you can open ```config/secrets.yml``` and set ```twitter_api_key``` and ```twitter_api_secret``` values.
```
TWITTER_API_KEY=djsdkjasbdkjasbdkasgdkasbdbs
TWITTER_API_SECRET=kljfkldjfkldsjfkldsjkfljdslkfjsflsdkfjs
```
- Open ```config/secrets.yml``` and set _username_ with the account name of the user that you want to get the relevant information. E.g.: If the username is set to justinbieber, then the application will list all relevant tweets and users for the user @justinbieber.
- Install the required gems.
```
bundle install
```
- Create the database.
```
ruby bin/rails db:migrate
```
- Run the application.
```
ruby bin/rails server
```
- Access [localhost:3000](http://localhost:3000) to see the relevant users and tweets for the given user (defined by _username_).

### Running the tests
- Go to the project's root directory.
- Install the required gems.
```
bundle install
```
- Create the database.
```
ruby bin/rails db:migrate RAILS_ENV=test
```
- Run the tests.
```
ruby bin/rails test
```

## Known issues
### SSL Certificate (Windows)
In Windows environment, the first localhost:3000 access gives a 500 error related to SSL certificate.
If this happens, just access localhost:3000 again.