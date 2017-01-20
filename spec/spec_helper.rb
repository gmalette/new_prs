$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "new_prs"
require "database_cleaner"

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
  config.before(:suite) do
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
