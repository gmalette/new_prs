module NewPrs
  module Actions
    class UpdatePullRequests
      def self.update_pull_requests(watched_users:, repo:)
        cursor = NewPrs::Cursor.where(resource: "pull_requests").first_or_initialize
        puts "Starting PR update at #{cursor.graphql_id.inspect}"

        NewPrs::Actions::FetchPullRequests.fetch_pull_requests(
          owner: repo.owner,
          name: repo.name,
          cursor: cursor.graphql_id,
        ) do |pull_request, pr_cursor|
          cursor.graphql_id = pr_cursor
          next unless author = watched_users[pull_request.author&.id]
          next if NewPrs::PullRequest.where(graphql_id: pull_request.id).exists?

          PullRequest.create!(
            repository: repo,
            user: author,
            graphql_id: pull_request.id,
            title: pull_request.title,
            seen: false,
            number: pull_request.number,
            state: pull_request.state,
            path: [repo.owner, repo.name, "pull", pull_request.number].join("/"),
          )
        end
      ensure
        cursor.save if cursor.graphql_id_changed?
      end
    end
  end
end
