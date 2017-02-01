require "spec_helper"

describe NewPrs::Actions::UpdateExistingPullRequests do
  describe ":update_existing_pull_requests" do
    it "fetches pull requests from GraphQL and calls UpdatePullRequest" do
      pull_request = create(:pull_request)

      node = build(
        :pull_request_node,
        id: pull_request.graphql_id,
      )
      expect(NewPrs::GithubClient)
        .to(receive(:query))
        .with(described_class::Query, variables: { ids: [pull_request.graphql_id] })
        .and_return(double("Response", data: double("data", nodes: [node])))

      expect(NewPrs::Actions::UpdatePullRequest)
        .to(receive(:update_pull_request))
        .with(
          repo: pull_request.repository,
          pull_request_node: NewPrs::Actions::UpdatePullRequest::PullRequestFragment.type,
          author: pull_request.user,
        )

      described_class.update_existing_pull_requests
    end
  end
end
