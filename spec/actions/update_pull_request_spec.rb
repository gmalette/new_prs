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
        seen: true,
        title: "previous title",
        state: "OPEN",
        github_created_at: DateTime.now.iso8601,
        github_updated_at: pull_request_node.updatedAt,
        path: "/titi/toto",
      )
      review_node = pull_request_node.reviews.edges.first.node

      review = NewPrs::PullRequestReview.create!(
        pull_request: pull_request,
        user: user,
        graphql_id: review_node.id,
        state: review_node.state,
      )

      expect {
        described_class.update_pull_request(
          repo: repo,
          pull_request_node: pull_request_node,
          author: user,
        )
      }.not_to(change { NewPrs::PullRequest.count })

      pull_request.reload

      expect(pull_request.reload.seen).to be(true)
      expect(pull_request.title).to(eq(pull_request_node.title))
    end

    it "marks PRs as unseen if they changed" do
      pull_request = NewPrs::PullRequest.create!(
        repository: repo,
        user: user,
        graphql_id: pull_request_node.id,
        number: pull_request_node.number,
        seen: true,
        title: "previous title",
        state: "OPEN",
        github_created_at: Time.at(0),
        github_updated_at: Time.at(0),
        path: "/titi/toto",
      )

      expect {
        described_class.update_pull_request(
          repo: repo,
          pull_request_node: pull_request_node,
          author: user,
        )
      }.not_to(change { NewPrs::PullRequest.count })

      expect(pull_request.reload.seen).to be(false)
    end

    it "updates reviews" do
      _pull_request = NewPrs::PullRequest.create!(
        repository: repo,
        user: user,
        graphql_id: pull_request_node.id,
        number: pull_request_node.number,
        seen: true,
        title: "previous title",
        state: "OPEN",
        github_created_at: DateTime.now.iso8601,
        github_updated_at: pull_request_node.updatedAt,
        path: "/titi/toto",
      )

      expect {
        described_class.update_pull_request(
          repo: repo,
          pull_request_node: pull_request_node,
          author: user,
        )
      }.to(change { NewPrs::PullRequestReview.count }.by(1))
    end
  end
end
