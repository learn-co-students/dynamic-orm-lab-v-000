require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord

    def self.table_name
        self.to_s.downcase.pluralize # #pluralize is from inflector lib.. otherwise use "#{data}s"
    end

    def self.column_names
      DB[:conn].results_as_hash = true
                                                  # PRAGMA http://www.tutorialspoint.com/sqlite/sqlite_pragma.htm
      sql = <<-SQL
        PRAGMA table_info('#{self.table_name}')
      SQL

      column_names = []
      DB[:conn].execute(sql).each do |col|
        column_names << col["name"]
      end
      column_names.compact #compact takes out 'nil' returns
    end

    def initialize(options={})
      options.each do |property, value|
        self.send("#{property}=", value) #unless property = "id"
      end
    end

    def table_name_for_insert
      self.class.table_name             # instance method so you need to get .class from the instance /// self ///
    end

    def col_names_for_insert
      self.class.column_names.delete_if {|col| col == "id"}.join(", ")
    end

    def values_for_insert
      values = []
      self.class.column_names.each do |col_name|
        values << "'#{send(col_name)}'" unless send(col_name).nil?
      end
      values.join(", ")
    end

    def save
      sql = "INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})"

      DB[:conn].execute(sql)

      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
    end

    def self.find_by_name(name)
      sql = "SELECT * FROM #{self.table_name} WHERE name = '#{name}'"
      DB[:conn].execute(sql).flatten
    end

    def self.find_by(hash)
      props = hash.collect {|property, value| property}.join(', ')
      vals = hash.collect {|property, value| value}.join(', ')

      sql ="SELECT * FROM #{self.table_name} WHERE #{props} = '#{vals}'"
      DB[:conn].execute(sql)
    end
end
