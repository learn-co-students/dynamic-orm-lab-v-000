require 'pry'
require 'sqlite3'
require 'rake'

DB = {:conn => SQLite3::Database.new("db/students.sqlite")}
DB[:conn].execute("DROP TABLE IF EXISTS students")

sql = <<-SQL
  CREATE TABLE IF NOT EXISTS students (
  id INTEGER PRIMARY KEY,
  name TEXT,
  grade INTEGER
  )
SQL

DB[:conn].execute(sql)
DB[:conn].results_as_hash = true
