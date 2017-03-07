module NewPrs
  module CLI
    class PullRequest
      def initialize(cli, user, pull_request)
        @cli = cli
        @user = user
        @pull_request = pull_request
      end

      def run

        system("open", url)

        reviewers = @pull_request.pull_request_reviews.map(&:user).uniq

        choice = @cli.choose do |menu|
          menu.header = "Mark as seen"
          menu.choice(:more, "Add scores for the reviews") if reviewers.any?
          menu.choice(:yes, "Mark the pull request as seen")
          menu.choice(:no, "Don't mark the pull request as seen")
        end

        if choice == :yes
          @pull_request.update(seen: true)
        elsif choice == :more
          PullRequestReviewReview.new(@cli, @pull_request).run
        end
      end
    end
  end
end
