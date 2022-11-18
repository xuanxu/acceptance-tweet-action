require "faraday"
require "faraday/retry"

default_mastodon_instance_url = "https://astrodon.social"

journal_name = ENV["JOURNAL_NAME"].to_s
paper_title = ENV["PAPER_TITLE"].to_s
paper_doi = ENV["PAPER_DOI"].to_s
mastodon_token = ENV["MASTODON_TOKEN"].to_s
mastodon_instance_url = ENV["MASTODON_INSTANCE_URL"] || default_mastodon_instance_url
mastodon_user = ENV["MASTODON_USER"]

text = %Q(Just published in #{journal_name}: '#{paper_title}' https://doi.org/#{paper_doi})

credentials = [mastodon_token, mastodon_instance_url, mastodon_user]

if credentials.any?{|c| c.empty?}
  system("echo '!! Error posting to Mastodon: Missing credentials'")
  system("echo 'toot_result=errored' >> $GITHUB_OUTPUT")
else
  begin
    headers = { "Authorization" => "Bearer #{mastodon_token}" }
    mastodon_instance_url += "/" unless mastodon_instance_url.end_with?("/")
    mastodon_user.prepend("@") unless mastodon_user.start_with?("@")
    mastodon_status_url = mastodon_instance_url + "api/v1/statuses"

    parameters = { status: text }

    headers["Idempotency-Key"] = Digest::SHA1.hexdigest(text)
    toot = Faraday.post(mastodon_status_url, parameters, headers)

    toot_url = mastodon_instance_url + mastodon_user + "/" + toot.response.id

    system("echo 'toot_url=#{toot_url}' >> $GITHUB_OUTPUT")
    system("echo 'toot_result=ok' >> $GITHUB_OUTPUT")
  rescue
    system("echo 'toot_result=errored' >> $GITHUB_OUTPUT")
    system("echo '!! Error posting to Mastodon: Sending toot failed'")
  end
end
