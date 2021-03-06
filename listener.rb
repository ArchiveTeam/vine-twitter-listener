require 'twitter'
require 'json'

require_relative 'workers'

client = Twitter::Streaming::Client.new do |config|
  config.consumer_key = ENV['CONSUMER_KEY']
  config.consumer_secret = ENV['CONSUMER_SECRET']
  config.access_token = ENV['ACCESS_TOKEN']
  config.access_token_secret = ENV['ACCESS_TOKEN_SECRET']
end

client.user do |object|
  case object
  when Twitter::Tweet
    Extractor.perform_async(object.text, object.uri.to_s)
  when Twitter::DirectMessage
  when Twitter::Streaming::StallWarning
    $stderr.puts 'WARNING: received StallWarning'
  end
end
