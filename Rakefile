require "bundler/gem_tasks"
require "rspec/core/rake_task"
require "new_prs"

RSpec::Core::RakeTask.new(:spec)

task default: :spec

namespace :seed do
  def use_stdout_logging
    logger = ActiveRecord::Base.logger

    begin
      ActiveRecord::Base.logger = Logger.new(STDOUT)
      yield
    ensure
      ActiveRecord::Base.logger = logger
    end
  end

  task :user do
    print "Login: "
    login = STDIN.gets.strip

    use_stdout_logging do
      NewPrs::Actions::SeedUser.seed_user(login: login)
    end
  end

  desc "Seed the initial uses from ENV"
  task :initial do
    use_stdout_logging do
      ENV["WATCHED_USER_LOGINS"].split(",").map(&:strip).each do |login|
        NewPrs::Actions::SeedUser.seed_user(login: login)
      end
      ENV["WATCHED_REPOS"].split(",").map(&:strip).each do |repo|
        owner, name = repo.split("/")
        NewPrs::Repository.where(owner: owner, name: name).first_or_create!
      end
      NewPrs::Actions::SeedSelf.seed_self
    end
  end

  desc "Update Pull Requests"
  task :update do
    watched_users = NewPrs::User.all.map { |user| [user.graphql_id, user] }.to_h
    repo = NewPrs::Repository.first

    use_stdout_logging do
      NewPrs::Actions::UpdatePullRequests.update_pull_requests(
        watched_users: watched_users,
        repo: repo,
      )
    end
  end

  task default: :initial
end

namespace :db do
  desc "Migrate the database"
  task :migrate do
    ActiveRecord::Migrator.migrate("db/migrate/")
    Rake::Task["db:schema"].invoke
    puts "Database migrated."
  end

  task :reset do
    File.unlink(NewPrs::DB_FILE)
    Rake::Task["db:migrate"].invoke
    Rake::Task["seed:initial"].invoke
  end

  desc 'Create a db/schema.rb file that is portable against any DB supported by AR'
  task :schema do
    require 'active_record/schema_dumper'
    filename = "db/schema.rb"
    File.open(filename, "w:utf-8") do |file|
      ActiveRecord::SchemaDumper.dump(ActiveRecord::Base.connection, file)
    end
  end
end
