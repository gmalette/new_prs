module NewPrs
  module Actions
    class UpdatePullRequest
      PullRequestFragment = GithubClient.parse(<<~GRAPHQL)
        fragment on PullRequest {
          title
          number
          id
          state
          createdAt
          author {
            ...NewPrs::Actions::FetchUser::UserFragment
          }
          reviews(first: 100, after: $after_review_id) {
            edges {
              node {
                id
                state
                author {
                  ...NewPrs::Actions::FetchUser::UserFragment
                }
                comments {
                  totalCount
                }
              }
            }
          }
        }
      GRAPHQL

      def self.update_pull_request(repo:, pull_request_node:, author:)
        pull_request = PullRequest.where(
          graphql_id: pull_request_node.id,
        ).first_or_initialize

        pull_request.update(
          repository: repo,
          user: author,
          title: pull_request_node.title,
          seen: false,
          number: pull_request_node.number,
          state: pull_request_node.state,
          github_created_at: pull_request_node.createdAt,
          path: [repo.owner, repo.name, "pull", pull_request_node.number].join("/"),
        )

        pull_request_node.reviews.edges.each do |review_edge|
          review_node = review_edge.node
          author = NewPrs::Actions::FetchUser::UserFragment.new(review_node.author)

          PullRequestReview.create!(
            pull_request: pull_request,
            user: NewPrs::Actions::FindOrCreateUser.find_or_create_user(
              graphql_id: author.id,
              login: author.login,
            ),
            graphql_id: review_node.id,
            state: review_node.state,
            comment_count: review_node.comments.totalCount,
          )
        end
      end
    end
  end
end
