# Open Journals :: Acceptance tweet

This action creates a tweet announcing the acceptance of a paper.

## Usage

Usually this action is used as a final step in a workflow accepting a paper after depositing and DOI generation is complete.
To be able to comment in a GitHub issue, the env variable `GH_ACCESS_TOKEN`should be set.

### Inputs

The action accepts the following inputs:

- **journal_name**: Required. The name of the journal.
- **paper_title**: Required. The title of the accepted paper.
- **paper_doi**: Required. The DOI of the accepted paper.
- **twitter_consumer_key**: Required. Twitter consumer key.
- **twitter_consumer_secret**: Required. Twitter consumer secret.
- **twitter_access_token**: Required. Twitter access token.
- **twitter_access_token_secret**: Required. Twitter access token secret.

### Example

Used as a step in a workflow `.yml` file in a repo's `.github/workflows/` directory passing custom input values from diferent sources: other step's outputs, secrets or directly:

````yaml
on:
  workflow_dispatch:

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
```

