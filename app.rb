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
  # return recent tweets
  result_type: "recent",
  # get extended tweets that include all the information we need
  # including media entities (images)
  tweet_mode: "extended")
  .take(3)
  .collect do |tweet|
    {
      :retweet_count => tweet.retweet_count,
      :tweet_body => "
      <div style='width: 700px;'>
        @#{tweet.user.screen_name}: #{tweet.to_h[:full_text]} <br />
        Created At: #{tweet.created_at} || Retweets: #{tweet.retweet_count} <br />
        <img style='width: 500px;' src='#{tweet.media[0].media_url_https.to_s}' />
      </div>
      "
    }

  end

  # return array of tweet hashes, sorted by retweets
  @tweets.sort_by! { |tweet| tweet[:retweet_count] }.reverse

  erb :index

end
