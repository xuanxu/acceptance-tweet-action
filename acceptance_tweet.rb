require "x"
require "json"

journal_name = ENV["JOURNAL_NAME"].to_s
paper_title = ENV["PAPER_TITLE"].to_s
paper_doi = ENV["PAPER_DOI"].to_s
twitter_consumer_key = ENV["TWITTER_CONSUMER_KEY"].to_s
twitter_consumer_secret = ENV["TWITTER_CONSUMER_SECRET"].to_s
twitter_access_token = ENV["TWITTER_ACCESS_TOKEN"].to_s
twitter_access_token_secret = ENV["TWITTER_ACCESS_TOKEN_SECRET"].to_s
twitter_user = ENV["TWITTER_USER"].to_s

tw_txt = %Q(Just published in #{journal_name}: '#{paper_title}' https://doi.org/#{paper_doi})

credentials = [twitter_consumer_key, twitter_consumer_secret, twitter_access_token, twitter_access_token_secret, twitter_user]

if credentials.any?{|c| c.to_s.strip.empty?}
  system("echo '!! Can't tweet: Missing Twitter credentials'")
  system("echo 'tweet_result=errored' >> $GITHUB_OUTPUT")
else
  begin
    x_credentials = {
      api_key:             twitter_consumer_key,
      api_key_secret:      twitter_consumer_secret,
      access_token:        twitter_access_token,
      access_token_secret: twitter_access_token_secret,
    }

    client = X::Client.new(**x_credentials)

    tweet_body = { text: tw_txt }
    tweet = client.post("tweets", tweet_body.to_json)

    url = "https://twitter.com/#{twitter_user}/status/#{tweet['data']['id']}"

    system("echo 'tweet_url=#{url}' >> $GITHUB_OUTPUT")
    system("echo 'tweet_result=ok' >> $GITHUB_OUTPUT")
  rescue Exception => e
    system("echo 'tweet_result=errored' >> $GITHUB_OUTPUT")
    system("echo '!! Error tweeting: Sending tweet failed: #{e.message}'")
  end
end
