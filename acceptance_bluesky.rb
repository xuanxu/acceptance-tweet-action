require "faraday"
require "json"

journal_name = ENV["JOURNAL_NAME"].to_s
paper_title = ENV["PAPER_TITLE"].to_s
paper_doi = ENV["PAPER_DOI"].to_s
bluesky_user = ENV["BLUESKY_USERNAME"].to_s
bluesky_pass = ENV["BLUESKY_PASSWORD"].to_s

login_url = "https://bsky.social/xrpc/com.atproto.server.createSession"
login_headers = { "Content-Type" => "application/json" }


link = "https://doi.org/#{paper_doi}"
text = %Q(Just published in #{journal_name}: '#{paper_title}' #{link})

credentials = [bluesky_user, bluesky_pass]

if credentials.any?{|c| c.to_s.strip.empty?}
  system("echo '!! Can't post to Bluesky: Missing credentials'")
  system("echo 'bluesky_result=errored' >> $GITHUB_OUTPUT")
else
  begin
    login_parameters = { identifier: bluesky_user, password: bluesky_pass }
    login = Faraday.post(login_url, login_parameters.to_json, login_headers)

    if login.status.between?(200, 299)
      login_response = JSON.parse(login.body)
      post_url = "https://bsky.social/xrpc/com.atproto.repo.createRecord"
      post_headers = { "Content-Type" => "application/json", "Authorization" => "Bearer #{login_response['accessJwt']}" }

      text_length = text.bytes.size
      link_length = link.bytes.size

      post_body = { repo: login_parameters[:identifier],
                    collection: "app.bsky.feed.post",
                    record: { text: text,
                              createdAt: Time.now.strftime('%Y-%m-%dT%H:%M:%SZ'),
                              langs: ["en-US"],
                              facets: [{
                                        index: { byteStart: (text_length - link_length), byteEnd: text_length},
                                        features: [{ "$type" => 'app.bsky.richtext.facet#link', uri: link }]
                                      }]
                            }
                  }
      post_response = Faraday.post(post_url, post_body.to_json, post_headers)
      if post_response.status.between?(200, 299)
        json_response = JSON.parse(post_response.body)
        post_id = json_response["uri"].split("/").last
        bluesky_url = "https://bsky.app/profile/#{login_parameters[:identifier]}/post/#{post_id}"
        system("echo 'bluesky_url=#{bluesky_url}' >> $GITHUB_OUTPUT")
        system("echo 'bluesky_result=ok' >> $GITHUB_OUTPUT")
      else
        system("echo '!! Error posting to Bluesky: Error #{post_response.status}'")
        system("echo 'bluesky_result=errored' >> $GITHUB_OUTPUT")
      end
    else
      system("echo '!! Can't login into Bluesky: Error #{login.status}'")
      system("echo 'bluesky_result=errored' >> $GITHUB_OUTPUT")
    end
  rescue
    system("echo '!! Error posting to Bluesky: Sending post failed'")
    system("echo 'bluesky_result=errored' >> $GITHUB_OUTPUT")
  end
end