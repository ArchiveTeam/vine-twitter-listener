require 'analysand'
require 'securerandom'
require 'sidekiq'

require_relative 'expand_shortened'

$db = Analysand::Database.new(ENV['VINE_DB_URL'])

class Extractor
  include Sidekiq::Worker
  include ExpandShortened

  def perform(text, tweet_uri)
    tcos = get_tcos_from_tweet(text)
    expanded = expand_tcos(tcos).select { |url| url =~ /vine\.co/ }
    $db.put!(SecureRandom.uuid, { urls: expanded, tweet_uri: tweet_uri })
  end
end

