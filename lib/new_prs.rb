require "new_prs/version"
require "active_record"
require "graphql/client"
require "graphql/client/http"
require "dotenv/load"
require "highline"
require "pry"

module NewPrs
  DB_FILE = File.join(Dir.home, ".new_prs.sqlite3")
  require "new_prs/record"
  require "new_prs/user"
  require "new_prs/pull_request_review"
  require "new_prs/review_review"
  require "new_prs/repository"
  require "new_prs/pull_request"
  require "new_prs/github_client"
  require "new_prs/graphql_throttle"
  require "new_prs/actions/fetch_user"
  require "new_prs/actions/seed_user"
  require "new_prs/actions/seed_self"
  require "new_prs/actions/find_or_create_user"
  require "new_prs/actions/update_pull_request"
  require "new_prs/actions/update_existing_pull_requests"
  require "new_prs/actions/fetch_pull_requests"
  require "new_prs/actions/fetch_new_pull_requests"
  require "new_prs/cli/menu"
  require "new_prs/cli/main"
  require "new_prs/cli/user"
  require "new_prs/cli/pull_request"
  require "new_prs/cli/pull_request_review_review"

  ActiveRecord::Base.establish_connection(
    adapter: "sqlite3",
    database: DB_FILE,
  )
end
