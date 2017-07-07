require 'dotenv/load'
require 'sinatra'
require 'twitter'
require 'flickraw'

# twitter setup
client = Twitter::REST::Client.new do |config|
  config.consumer_key        = ENV['TWITTER_API_KEY']
  config.consumer_secret     = ENV['TWITTER_SECRET']
  config.access_token        = ENV['TWITTER_ACCESS_TOKEN']
  config.access_token_secret = ENV['TWITTER_ACCESS_SECRET']
end

#flickr setup
FlickRaw.api_key = ENV['FLICKR_API_KEY']
FlickRaw.shared_secret = ENV['FLICKR_SECRET']

get '/twitter' do
  @tweets = client.search(
  "#dctech
  filter:images
  -filter:retweets",
  # return recent tweets
  result_type: "recent",
  # get extended tweets that include all the information we need
  # including media entities (images)
  tweet_mode: "extended")
  .collect do |tweet|
    {
      :retweet_count => tweet.retweet_count,
      :tweet_body => "
      <div style='width: 700px; margin: 20px 0px 30px 0px;'>
        <img style='width: 500px;' src='#{tweet.media[0].media_url_https.to_s}' />
        <p><strong>@#{tweet.user.screen_name}:</strong> #{tweet.to_h[:full_text]}</p>
        <p><em>Timestamp: #{tweet.created_at}</em></p>
        <p><strong>Retweets: #{tweet.retweet_count}</strong></p>
      </div>
      "
    }
  end

  # return array of tweet hashes, sorted by retweets
  @tweets.sort_by! { |tweet| tweet[:retweet_count] }.reverse!

  erb :twitter
end

get '/flickr' do
  # get all the photos that meet our search criteria
  photos_dump = flickr.photos.search :tags => "#DCtech", :min_upload_date => Time.now - 16239599, :extras => "url_z, count_faves, date_upload"

  # use the records to populate photo_body and photo_faves for use in the view
  @photos = photos_dump.collect do |photo|
    {
      :photo_body => "
      <h2>#{photo.title}</h2>
      <img src='#{photo.url_z}' />
      <p><strong>Faves: #{photo.count_faves}</strong></p>
      ",
      :photo_faves => photo.count_faves
    }
  end

  # return an array of hashes, sorted by favorites
  @photos.sort_by! { |photo| photo[:photo_faves] }.reverse!

  erb :flickr
end
