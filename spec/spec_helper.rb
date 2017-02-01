$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "new_prs"
require "database_cleaner"
require "factory_girl"

test_db_file = Pathname.new("./tmp/new_prs_test.sqlite3").expand_path
FileUtils.mkdir_p(test_db_file.dirname.to_s)
File.unlink(test_db_file) if File.exist?(test_db_file)

ActiveRecord::Base.establish_connection(
  adapter: "sqlite3",
  database: test_db_file,
)

load("./Rakefile")
Rake::Task["db:migrate"].invoke

RSpec.configure do |config|
  config.include FactoryGirl::Syntax::Methods

  config.before(:suite) do
    FactoryGirl.find_definitions
    DatabaseCleaner.clean_with(:truncation)
  end

  config.before(:each) do
    DatabaseCleaner.strategy = :transaction
  end

  config.before(:each, :js => true) do
    DatabaseCleaner.strategy = :truncation
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end
end

FactoryGirl.define do
  factory :user, class: NewPrs::User do
    login("gmalette")
    graphql_id("user_graphql_id")
    myself(false)
  end

  factory :repository, class: NewPrs::Repository do
    owner("gmalette")
    name("new_prs")
    last_pull_request_cursor(nil)
  end

  factory :pull_request, class: NewPrs::PullRequest do
    user
    repository
    title("Fix All The Things")
    seen(false)
    graphql_id("pull_request_graphql_id")
    number(1234)
    state("OPEN")
    path("gmalette/new_prs/pull/1")
    github_created_at { DateTime.now }
  end

  factory :pull_request_node, class: NewPrs::Actions::UpdatePullRequest::PullRequestFragment do
    title("new pull_request title")
    number(1234)
    id("abcd")
    state("OPEN")
    createdAt(DateTime.now)
    author({ "id" => "abcd1234" })
    reviews({
      "edges" => [
        {
          "node" => {
            "state" => "OPEN",
            "author" => { "id" => 1234, },
            "comments" => { "totalCount" => 1 },
          },
        },
      ],
    })

    initialize_with { attributes.stringify_keys }
  end
end
