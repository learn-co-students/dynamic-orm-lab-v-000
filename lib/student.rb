require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'interactive_record.rb'

class Student < InteractiveRecord

    attr_accessor :name, :album
    attr_reader :id
 
    def initialize(id=nil, name, album)
        @id = id
        @name = name
        @album = album
    end

    def self.table_name
        sql = <<-SQL
        CREATE TABLE IF NOT EXISTS students (
            id INTEGER PRIMARY KEY,
            name TEXT,
            grade INTEGER
        ) 
        SQL 
        DB[:conn].execute(sql)
    end
end
