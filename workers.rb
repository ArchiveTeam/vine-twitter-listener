require 'sidekiq'
require 'securerandom'
require_relative 'expand_shortened'

$db = Analysand::Database.new('http://couchdb:5984/vines')

class Extractor
  include Sidekiq::Worker
  include ExpandShortened

  def perform(text, tweet_uri, in_reply_to_id)
    tcos = get_tcos_from_tweet(text)
    expanded = expand_tcos(tcos).select { |url| url =~ /vine\.co/ }
    $db.put!(SecureRandom.uuid, { urls: expanded, tweet_uri: tweet_uri, in_reply_to_tweet_id: in_reply_to_id })
  end
end

