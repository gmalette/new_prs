module NewPrs
  module CLI
    class PullRequestReviewReview
      def initialize(cli, pull_request)
        @cli = cli
        @pull_request = pull_request
      end

      def run
        reviewers = @pull_request.pull_request_reviews.map(&:user).uniq

        while true do
          prompt = "Reviewers:\n"
          prompt += reviewers.map.with_index do |reviewer, index|
            "#{index + 1}. #{reviewer.login}"
          end.join("\n")
          @cli.say(prompt)

          reviewer_index = @cli.ask("Which reviewer?", Integer) { |q| q.in = (0..reviewers.count) } - 1

          if reviewer_index >= 0
            reviewer = reviewers[reviewer_index]
            @cli.say("Reviewing the review of #{reviewer.login}")
            score = @cli.ask("Score (-5..5)?", Integer) { |q| q.in = -5..5 }
            comment = @cli.ask("Comment?", String)
            NewPrs::ReviewReview.create!(
              user: reviewer,
              pull_request: @pull_request,
              score: score,
              comment: comment,
            )
          else
            return
          end
        end
      end
    end
  end
end
