require "bundler/gem_tasks"
require "rspec/core/rake_task"
require "new_prs"

RSpec::Core::RakeTask.new(:spec)

task default: :spec

namespace :seed do
  task :user do
    print "Login: "
    login = STDIN.gets.strip
    logger = ActiveRecord::Base.logger

    begin
      ActiveRecord::Base.logger = Logger.new(STDOUT)
      NewPrs::Actions::SeedUser.seed_user(login: login)
    ensure
      ActiveRecord::Base.logger = logger
    end
  end

  task :initial do
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
