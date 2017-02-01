require "spec_helper"

describe NewPrs::Actions::FetchNewPullRequests do
  let(:repository) {
    create(:repository)
  }

  describe "fetch_new_pull_requests" do
    it "queries FetchPullRequests" do
      expect(NewPrs::Actions::FetchPullRequests)
        .to(receive(:fetch_pull_requests))
        .with(owner: repository.owner, name: repository.name, cursor: nil)

      described_class.fetch_new_pull_requests(watched_users: {}, repo: repository)
    end

    it "restarts from a previous cursor if available" do
      id = "test"
      repository.last_pull_request_cursor = id

      expect(NewPrs::Actions::FetchPullRequests)
        .to(receive(:fetch_pull_requests))
        .with(owner: repository.owner, name: repository.name, cursor: id)

      described_class.fetch_new_pull_requests(watched_users: {}, repo: repository)
    end

    it "creates PullRequests and PullRequestReviews with yielded values if it's from a watched user" do
      user = create(:user)
      pull_request = NewPrs::Actions::UpdatePullRequest::PullRequestFragment.new(
        "id" => 1111,
        "author" => { "id" => user.graphql_id, "login" => user.login },
        "title" => "awesome pull request",
        "number" => 10,
        "state" => "open",
        "path" => "titi/toto/10",
        "createdAt" => DateTime.now,
        "reviews" => {
          "edges" => [
            {
              "node" => {
                "id" => 2222,
                "state" => "APPROVED",
                "author" => {
                  "id" => user.graphql_id,
                  "login" => user.login,
                },
                "comments" => {
                  "totalCount" => 0,
                },
              },
            },
          ],
        }
      )

      expect(NewPrs::Actions::FetchPullRequests)
        .to(receive(:fetch_pull_requests))
        .and_yield(pull_request, "1234")

      expect {
        described_class.fetch_new_pull_requests(
          watched_users: { user.graphql_id => user },
          repo: repository,
        )
      }.to(
        change { NewPrs::PullRequest.count }.by(1)
        .and(change { NewPrs::PullRequestReview.count }.by(1))
      )
    end

    it "doesn't create PullRequests if it's not a watched user" do
      pull_request = double(
        "PullRequests",
        id: "1111",
        author: { "id" => "abcd" },
        title: "awesome pull request",
        number: "10",
        state: "open",
        path: "titi/toto/10",
      )
      expect(NewPrs::Actions::FetchPullRequests)
        .to(receive(:fetch_pull_requests))
        .and_yield(pull_request, "1234")

      expect {
        described_class.fetch_new_pull_requests(
          watched_users: {},
          repo: repository,
        )
      }.not_to(change { NewPrs::PullRequest.count })
    end
  end
end
