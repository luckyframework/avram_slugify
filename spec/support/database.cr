class AppDatabase < Avram::Database
end

AppDatabase.configure do |settings|
  settings.url = ENV["DATABASE_URL"]? || Avram::PostgresURL.build(
    database: "avram_slugify",
    hostname: "localhost",
    username: "postgres",
    password: "postgres"
  )
end

Avram.configure do |settings|
  settings.database_to_migrate = AppDatabase
end

class CreateUsers::V0 < Avram::Migrator::Migration::V1
  def migrate
    create table_for(User) do
      primary_key id : Int64
      add slug : String, unique: true
      add job_title : String?
      add last_name : String?
      add first_name : String?
    end
  end

  def rollback
    drop table_for(User)
  end
end

Db::Drop.new.call
Db::Create.new(quiet: true).call
Db::Migrate.new(quiet: true).call

Spec.before_each do
  AppDatabase.truncate
end
