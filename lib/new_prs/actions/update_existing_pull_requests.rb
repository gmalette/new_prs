module NewPrs
  module Actions
    class UpdateExistingPullRequests
      Query = GithubClient.parse(<<~GRAPHQL)
        query($ids: [ID!]!, $after_review_id: String) {
          nodes(ids: $ids) {
            ...NewPrs::Actions::UpdatePullRequest::PullRequestFragment
          }
        }
      GRAPHQL

      def self.update_existing_pull_requests
        pull_requests = NewPrs::PullRequest.all
          .where(state: "OPEN").or(NewPrs::PullRequest.where(state: "MERGED", seen: false))
                          .includes(:user, :repository)
          .in_groups_of(100)
          .map(&:compact)

        pull_requests.each do |prs|
          prs_by_id = prs.map{ |pr| [pr.graphql_id, pr] }.to_h
          response = GithubClient.query(
            Query,
            variables: { ids: prs_by_id.keys },
          )

          NewPrs::GraphQLThrottle.examine(response)

          response.data.nodes.each do |pull_request_node|
            pull_request_node = NewPrs::Actions::UpdatePullRequest::PullRequestFragment.new(pull_request_node)
            pull_request = prs_by_id[pull_request_node.id]
            NewPrs::Actions::UpdatePullRequest.update_pull_request(
              repo: pull_request.repository,
              pull_request_node: pull_request_node,
              author: pull_request.user,
            )
          end
        end
      end
    end
  end
end
