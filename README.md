# Open Journals :: Acceptance tweet

This action creates a tweet and/or a toot announcing the acceptance of a paper.

## Usage

Usually this action is used as a final step in a workflow accepting a paper after depositing and DOI generation is complete.
To receive a comment in a GitHub issue with a link to the tweet/toot, the input variables `gh_token`, `issue_id` and `reviews_repo` should be passed.

### Inputs

The action accepts the following inputs:

- **journal_name**: Required. The name of the journal.
- **paper_title**: Required. The title of the accepted paper.
- **paper_doi**: Required. The DOI of the accepted paper.
- **reviews_repo**: Required. The repository containing the review issue for the paper.
- **issue_id**: Required. The issue number of the submission (to post a link to the tweet or toot).
- **gh_token**: Required. The github token to use for replying to the review issue.

- **twitter_consumer_key**: Optional. Twitter consumer key. Required if sending post to Twitter.
- **twitter_consumer_secret**: Optional. Twitter consumer secret. Required if sending post to Twitter.
- **twitter_access_token**: Optional. Twitter access token. Required if sending post to Twitter.
- **twitter_access_token_secret**: Optional. Twitter access token secret. Required if sending post to Twitter.

- **mastodon_access_token**: Optional. Mastodon access token. Required if sending post to Mastodon.
- **mastodon_instance_url**: Optional. Mastodon instance URL. Required if sending post to Mastodon.
- **mastodon_user**: Optional. Mastodon user (without instance info). Required if sending post to Mastodon.


### Example

Used as a step in a workflow `.yml` file in a repo's `.github/workflows/` directory passing custom input values from diferent sources: event inputs, other step's outputs, secrets and directly:

````yaml
on:
  workflow_dispatch:
   inputs:
      issue_id:
        description: 'The issue number of the submission'
jobs:
  processing:
    runs-on: ubuntu-latest
    env:
      GH_ACCESS_TOKEN: ${{ secrets.BOT_TOKEN }}
    steps:
      - compile paper ...
      - generate files...
      - deposit paper...
      - name: Tweet
        uses: xuanxu/acceptance-tweet-action@main
        with:
          journal_name: "TEST JOURNAL"
          paper_title: ${{ steps.generate-files.outputs.paper_title}}
          paper_doi: ${{steps.deposit.outputs.paper_doi}}
          twitter_consumer_key: ${{ secrets.TWITTER_CONSUMER_KEY }}
          twitter_consumer_secret: ${{ secrets.TWITTER_CONSUMER_SECRET }}
          twitter_access_token: ${{ secrets.TWITTER_ACCESS_TOKEN }}
          twitter_access_token_secret: ${{ secrets.TWITTER_ACCESS_TOKEN_SECRET }}
          mastodon_access_token: ${{ secrets.MASTODON_ACCESS_TOKEN }}
          mastodon_instance_url: ${{ secrets.MASTODON_INSTANCE_URL }}
          mastodon_user: ${{ secrets.MASTODON_USER }}
          reviews_repo: openjournals/joss-reviews
          issue_id: ${{ github.event.inputs.issue_id }}
          gh_token: ${{ secrets.GITHUB_TOKEN }}
```

