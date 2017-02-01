module NewPrs
  module Actions
    class FetchNewPullRequests
      def self.fetch_new_pull_requests(watched_users:, repo:)
        cursor = repo.last_pull_request_cursor
        puts "Starting PR update at #{cursor.inspect}"

        NewPrs::Actions::FetchPullRequests.fetch_pull_requests(
          owner: repo.owner,
          name: repo.name,
          cursor: cursor,
        ) do |pull_request, pr_cursor|
          repo.last_pull_request_cursor = pr_cursor
          author_fragment = NewPrs::Actions::FetchUser::UserFragment.new(pull_request.author)
          next unless author = watched_users[author_fragment&.id]
          next if NewPrs::PullRequest.where(graphql_id: pull_request.id).exists?

          NewPrs::Actions::UpdatePullRequest.update_pull_request(
            repo: repo,
            pull_request_node: pull_request,
            author: author,
          )
        end
      ensure
        repo.save if repo.last_pull_request_cursor_changed?
      end
    end
  end
end
