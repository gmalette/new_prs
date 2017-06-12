module NewPrs
  module CLI
    class Main
      def initialize(cli)
        @cli = cli
      end

      def run
        while true do
          NewPrs::CLI::Menu.new(@cli)
            .command("q", "Quit") { quit }
            .list(-> { user_menus }, all: "a")
            .run
        end
      rescue EOFError
      end

      def pull_requests_menus(user)
        user.pull_requests.where(seen: false).map do |pr|
          reviewers_menus = pr.pull_request_reviews.map(&:user).uniq.map do |user|
            menu =
              NewPrs::CLI::Menu.new(@cli)
                .command("1", "WTF") { score_review(@cli, pr, user, -1); :term }
                .command("2", "OK") { score_review(@cli, pr, user, 0); :term }
                .command("3", "Stellar") { score_review(@cli, pr, user, 1); :term }

            [user.login, menu]
          end

          review_menu = NewPrs::CLI::Menu.new(@cli)
            .list(reviewers_menus, all: "a")

          pr_menu =
            NewPrs::CLI::Menu.new(@cli)
              .command("m", "Mark as read") { pr.update(seen: true); :term }
              .command("s", "Score this review") { |*a| review_menu.run(*a) }
              .command("o", "open") { system("open", pr.url) }
              .command("q", "Quit") { quit }

          ["#{pr_state(pr)} #{pr.title}", pr_menu]
        end
      end

      def user_menus
        unseen_prs_by_author =
          NewPrs::PullRequest
            .includes(:user)
            .joins(:user)
            .where(seen: false, users: { watched: true })
            .group_by(&:user)

        unseen_prs_by_author.map do |user, prs|
          menu =
            NewPrs::CLI::Menu.new(@cli)
              .list(-> { pull_requests_menus(user) }, all: "a")

          pr_count_by_state = prs.group_by(&:state).sort.map do |(state, state_prs)|
            HighLine.color(state_prs.count.to_s, state_color(state))
          end.join(", ")

          ["#{user.login} (#{pr_count_by_state})", menu]
        end
      end

      def score_review(cli, pr, user, score)
        comment = cli.ask("Comment?", String)
        NewPrs::ReviewReview.create!(
          user: user,
          pull_request: pr,
          score: score,
          comment: comment,
        )
      end

      def quit
        puts "Exitting"
        exit
      end

      def pr_state(pr)
        HighLine.color(pr.state[0], state_color(pr.state))
      end

      def state_color(state)
        case state
        when "MERGED"
          :rgb_6E5494
        when "CLOSED"
          :rgb_BD2C00
        when "OPEN"
          :rgb_6CC644
        else
          raise "unknown color for #{pr.state}"
        end
      end
    end
  end
end
