module NewPrs
  module CLI
    class Main
      def initialize(cli)
        @cli = cli
      end

      def run
        while true do
          unseen_prs_by_author = NewPrs::PullRequest.where(seen: false).includes(:user).group_by(&:user)
          prompt = "Which author's PR do you want to see?\n"
          prompt += unseen_prs_by_author.map.with_index do |(user, prs), index|
            "#{index + 1}. #{user.login} (#{prs.count})"
          end.join("\n")

          @cli.say(prompt)

          user_index = @cli.ask("Which user?", Integer) { |q| q.in = (1..unseen_prs_by_author.count) } - 1

          NewPrs::CLI::User.new(@cli, unseen_prs_by_author.keys[user_index]).run
        end
      rescue EOFError
      end
    end
  end
end
