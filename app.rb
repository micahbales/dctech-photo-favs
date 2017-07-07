require 'dotenv/load'
require 'sinatra'
require 'oauth'
require 'twitter'

client = Twitter::REST::Client.new do |config|
  config.consumer_key        = ENV['TWITTER_API_KEY']
  config.consumer_secret     = ENV['TWITTER_SECRET']
  config.access_token        = ENV['TWITTER_ACCESS_TOKEN']
  config.access_token_secret = ENV['TWITTER_ACCESS_SECRET']
end

get '/' do

  @tweets = client.search(
  "#dctech
  filter:images
  -filter:retweets",
  result_type: "recent")
  .take(3)
  .collect do |tweet|
    "#{tweet.user.screen_name}: #{tweet.text} <br />
    Created At: #{tweet.created_at} || Retweets: #{tweet.retweet_count}"
  end

  erb :index

end
