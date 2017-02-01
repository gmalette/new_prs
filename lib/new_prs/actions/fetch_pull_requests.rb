module NewPrs
  module Actions
    class FetchPullRequests
      Query = GithubClient.parse(<<~GRAPHQL)
        query($owner: String!, $name: String!, $after_pull_request: String, $after_review_id: String) {
          repository(owner: $owner, name: $name) {
            id
            pullRequests(first: 100, after: $after_pull_request) {
              edges {
                node {
                  ...NewPrs::Actions::UpdatePullRequest::PullRequestFragment
                }
                cursor
              }
              pageInfo {
                endCursor
                hasNextPage
              }
            }
          }
        }
      GRAPHQL

      # private_constant :Query

      def self.fetch_pull_requests(owner:, name:, cursor: nil)
        has_next_page = true

        while has_next_page do
          response = GithubClient.query(
            Query,
            variables: { owner: owner, name: name, after_pull_request: cursor },
          )

          if response.data.nil?
            if response.errors.any?
              puts "Aborting query to fetch new pull requests because of errors:"
              puts "  #{response.errors.messages.inspect}"
            else
              puts "Aborting query to fetch new pull requests, unknown reason"
            end

            return
          end

          has_next_page = response.data.repository.pullRequests.pageInfo.hasNextPage
          pull_request_edges = response.data.repository.pullRequests.edges
          puts "Found #{pull_request_edges.count} pull requests"
          return if pull_request_edges.empty?
          cursor = pull_request_edges.last.cursor

          response.data.repository.pullRequests.edges.each do |edge|
            pull_request = NewPrs::Actions::UpdatePullRequest::PullRequestFragment.new(edge.node)
            yield(pull_request, cursor)
          end
        end
      end
    end
  end
end
