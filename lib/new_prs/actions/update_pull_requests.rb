module NewPrs
  module Actions
    class UpdatePullRequests
      def self.update_pull_requests(watched_users:, repo:)
        cursor = repo.last_pull_request_cursor
        puts "Starting PR update at #{cursor.graphql_id.inspect}"

        NewPrs::Actions::FetchPullRequests.fetch_pull_requests(
          owner: repo.owner,
          name: repo.name,
          cursor: cursor,
        ) do |pull_request, pr_cursor|
          repo.last_pull_request_cursor = pr_cursor
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
            github_created_at: pull_request.createdAt,
            path: [repo.owner, repo.name, "pull", pull_request.number].join("/"),
          )
        end
      ensure
        repo.save if cursor.last_pull_request_cursor_changed?
      end
    end
  end
end
