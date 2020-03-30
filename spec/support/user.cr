require "./database"

class User < Avram::Model
  def self.database : AppDatabase.class
    AppDatabase
  end

  skip_default_columns

  table do
    primary_key id : Int64
    column slug : String
    column first_name : String?
    column last_name : String?
    column job_title : String?
  end
end

class UserQuery < User::BaseQuery
end

class UserBox < Avram::Box
end
