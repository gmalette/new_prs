require "spec_helper"

describe NewPrs::Actions::UpdatePullRequests do
  let(:repository) {
    NewPrs::Repository.create!(
      owner: "Shopify",
      name: "shopify",
    )
  }

  describe "update_pull_requests" do
    it "queries FetchPullRequests" do
      expect(NewPrs::Actions::FetchPullRequests)
        .to(receive(:fetch_pull_requests))
        .with(owner: "Shopify", name: "shopify", cursor: nil)

      described_class.update_pull_requests(watched_users: {}, repo: repository)
    end

    it "restarts from a previous cursor if available" do
      id = "test"
      NewPrs::Cursor.create!(resource: "pull_requests", graphql_id: id)

      expect(NewPrs::Actions::FetchPullRequests)
        .to(receive(:fetch_pull_requests))
        .with(owner: "Shopify", name: "shopify", cursor: id)

      described_class.update_pull_requests(watched_users: {}, repo: repository)
    end

    it "creates PullRequests with yielded values if it's from a watched user" do
      user = NewPrs::User.create!(login: "abcd", graphql_id: "abcd")
      pull_request = double(
        "PullRequests",
        id: "1111",
        author: double(id: "abcd"),
        title: "awesome pull request",
        number: "10",
        state: "open",
        path: "titi/toto/10",
      )
      expect(NewPrs::Actions::FetchPullRequests)
        .to(receive(:fetch_pull_requests))
        .and_yield(pull_request, "1234")

      expect {
        described_class.update_pull_requests(
          watched_users: { "abcd" => user },
          repo: repository,
        )
      }.to(change { NewPrs::PullRequest.count }.by(1))
    end

    it "doesn't create PullRequests if it's not a watched user" do
      pull_request = double(
        "PullRequests",
        id: "1111",
        author: double(id: "abcd"),
        title: "awesome pull request",
        number: "10",
        state: "open",
        path: "titi/toto/10",
      )
      expect(NewPrs::Actions::FetchPullRequests)
        .to(receive(:fetch_pull_requests))
        .and_yield(pull_request, "1234")

      expect {
        described_class.update_pull_requests(
          watched_users: {},
          repo: repository,
        )
      }.not_to(change { NewPrs::PullRequest.count })
    end
  end
end
