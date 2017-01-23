module NewPrs
  module CLI
    class User
      def initialize(cli, user)
        @cli = cli
        @user = user
      end

      def run
        while true do
          prs = @user.pull_requests.where(seen: false)
          prompt = "Pull requests for #{@user.login}:\n"
          prompt += "0. More choices\n"
          prompt += prs.map.with_index do |pr, index|
            "#{index + 1}. (#{pr_state(pr)}) #{pr.title}"
          end.join("\n")
          @cli.say(prompt)

          pr_index = @cli.ask("Which pull request?", Integer) { |q| q.in = (0..prs.count) } - 1

          if pr_index < 0
            prompt = "0. Mark all as read\n1. Return"
            case @cli.ask(prompt, Integer) { |q| q.in = (0..1) }
            when 0
              prs.each { |pr| pr.update(seen: true) }
              break
            when 1
              break
            end
          else
            NewPrs::CLI::PullRequest.new(@cli, @user, prs[pr_index]).run
          end
        end
      end

      def pr_state(pr)
        color =
          case pr.state
          when "MERGED"
            :rgb_6E5494
          when "CLOSED"
            :rgb_BD2C00
          when "OPEN"
            :rgb_6CC644
          else
            raise "unknown color for #{pr.state}"
          end

        HighLine.color(pr.state[0], color)
      end
    end
  end
end
