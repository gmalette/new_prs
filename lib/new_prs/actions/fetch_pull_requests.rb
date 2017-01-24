module NewPrs
  module Actions
    class FetchPullRequests
      Query = GithubClient.parse(<<~GRAPHQL)
        query($owner: String!, $name: String!, $after: String) {
          repository(owner: $owner, name: $name) {
            id
            pullRequests(first: 100, after: $after) {
              edges {
                node {
                  title
                  number
                  id
                  state
                  createdAt
                  author {
                    id
                  }
                  reviews(first: 100) {
                    edges {
                      node {
                        state
                        author {
                          id
                        }
                      }
                    }
                  }
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
            variables: { owner: owner, name: name, after: cursor },
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
          cursor = response.data.repository.pullRequests.edges.last.cursor

          puts "Found #{response.data.repository.pullRequests.edges.count} pull requests"
          response.data.repository.pullRequests.edges.each do |edge|
            yield(edge.node, cursor)
          end
        end
      end
    end
  end
end
