require "spec_helper"

describe NewPrs::CLI::PullRequestReviewReview do
  describe "#run" do
    it "asks for the reviewer, score, and comment, and creates a PullRequestReviewReview" do
      cli = double
      allow(cli).to(receive(:say))
      expect(cli).to(receive(:ask).and_return(1, 5, "comment", 0))

      user = create(:user)
      pull_request = create(:pull_request)
      allow(pull_request).to(receive(:pull_request_reviews).and_return([double(user: user)]))

      expect {
        NewPrs::CLI::PullRequestReviewReview.new(cli, pull_request).run
      }.to(change { NewPrs::ReviewReview.count }.by(1))
    end
  end
end
