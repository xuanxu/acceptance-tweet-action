require "twitter"

journal_name = ENV["JOURNAL_NAME"].to_s
paper_title = ENV["PAPER_TITLE"].to_s
paper_doi = ENV["PAPER_DOI"].to_s
twitter_consumer_key = ENV["TWITTER_CONSUMER_KEY"].to_s
twitter_consumer_secret = ENV["TWITTER_CONSUMER_SECRET"].to_s
twitter_access_token = ENV["TWITTER_ACCESS_TOKEN"].to_s
twitter_access_token_secret = ENV["TWITTER_ACCESS_TOKEN_SECRET"].to_s

tw_txt = %Q(Just published in #{journal_name}: '#{paper_title}' https://doi.org/#{paper_doi})

credentials = [twitter_consumer_key, twitter_consumer_secret, twitter_access_token, twitter_access_token_secret]

if credentials.any?{|c| c.to_s.strip.empty?}
  system("echo '!! Can't tweet: Missing Twitter credentials'")
  system("echo 'tweet_result=errored' >> $GITHUB_OUTPUT")
else
  begin
    client = Twitter::REST::Client.new do |c|
      c.consumer_key        = twitter_consumer_key
      c.consumer_secret     = twitter_consumer_secret
      c.access_token        = twitter_access_token
      c.access_token_secret = twitter_access_token_secret
    end

    tweet = client.update(tw_txt)

    system("echo 'tweet_url=#{tweet.uri.to_s}' >> $GITHUB_OUTPUT")
    system("echo 'tweet_result=ok' >> $GITHUB_OUTPUT")
  rescue
    system("echo 'tweet_result=errored' >> $GITHUB_OUTPUT")
    system("echo '!! Error tweeting: Sending tweet failed'")
  end
end
