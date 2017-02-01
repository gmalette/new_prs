require "spec_helper"

describe NewPrs::Actions::UpdatePullRequest do
  describe ":update_pull_request" do
    let(:pull_request_node) {
      NewPrs::Actions::UpdatePullRequest::PullRequestFragment.new(build(:pull_request_node))
    }
    let(:repo) { create(:repository) }
    let(:user) { create(:user) }

    it "creates pull requests and reviews" do
      expect {
        described_class.update_pull_request(
          repo: repo,
          pull_request_node: pull_request_node,
          author: user,
        )
      }.to(
        change { NewPrs::PullRequest.count }.by(1)
        .and(change { NewPrs::PullRequestReview.count }.by(1))
      )
    end

    it "updates pull requests when already created" do
      pull_request = NewPrs::PullRequest.create!(
        repository: repo,
        user: user,
        graphql_id: pull_request_node.id,
        number: pull_request_node.number,
        seen: false,
        title: "previous title",
        state: "OPEN",
        github_created_at: DateTime.now,
        path: "/titi/toto",
      )

      expect {
        described_class.update_pull_request(
          repo: repo,
          pull_request_node: pull_request_node,
          author: user,
        )
      }.not_to(change { NewPrs::PullRequest.count })

      pull_request.reload

      expect(pull_request.title).to(eq(pull_request_node.title))
    end

    it "updates reviews" do
    end
  end
end
