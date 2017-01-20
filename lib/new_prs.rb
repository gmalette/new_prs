require "new_prs/version"
require "active_record"
require "graphql/client"
require "graphql/client/http"
require 'dotenv/load'
require "pry"

module NewPrs
  DB_FILE = File.join(Dir.home, ".new_prs.sqlite3")
  require "new_prs/record"
  require "new_prs/user"
  require "new_prs/github_client"
  require "new_prs/actions/fetch_user"
  require "new_prs/actions/seed_user"

  ActiveRecord::Base.establish_connection(
    adapter: "sqlite3",
    database: DB_FILE,
  )
end
