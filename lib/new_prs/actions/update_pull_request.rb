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
          updatedAt
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
        ).first_or_initialize(github_updated_at: DateTime.now)

        seen = !!(pull_request.seen && pull_request.github_updated_at >= DateTime.parse(pull_request_node.updatedAt))

        pull_request.update(
          repository: repo,
          user: author,
          title: pull_request_node.title,
          seen: seen,
          number: pull_request_node.number,
          state: pull_request_node.state,
          github_created_at: pull_request_node.createdAt,
          github_updated_at: pull_request_node.updatedAt,
          path: [repo.owner, repo.name, "pull", pull_request_node.number].join("/"),
        )

        pull_request_node.reviews.edges.each do |review_edge|
          review_node = review_edge.node
          author_node = NewPrs::Actions::FetchUser::UserFragment.new(review_node.author)
          author = NewPrs::Actions::FindOrCreateUser.find_or_create_user(
            graphql_id: author_node.id,
            login: author_node.login,
          )

          next if PullRequestReview.where(graphql_id: review_node.id).exists?
          next unless author.watched?

          PullRequestReview.create!(
            pull_request: pull_request,
            user: author,
            graphql_id: review_node.id,
            state: review_node.state,
            comment_count: review_node.comments.totalCount,
          )
        end
      end
    end
  end
end
