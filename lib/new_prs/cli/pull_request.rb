module NewPrs
  module CLI
    class PullRequest
      def initialize(cli, user, pull_request)
        @cli = cli
        @user = user
        @pull_request = pull_request
      end

      def run
        url = ["https://github.com", @pull_request.path].join("/")
        @cli.say("Opening pull request\n#{url}")

        system("open", url)

        choice = @cli.choose do |menu|
          menu.header = "Mark as seen"
          menu.choice(:yes, "Mark the pull request as seen")
          menu.choice(:no, "Don't mark the pull request as seen")
        end

        if choice == :yes
          @pull_request.update(seen: true)
        end
      end
    end
  end
end
