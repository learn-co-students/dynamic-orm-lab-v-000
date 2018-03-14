require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'interactive_record.rb'
require 'pry'
class InteractiveRecord

    def self.table_name
      self.to_s.downcase.pluralize
    end

    def self.column_names
      DB[:conn].results_as_hash = true
      sql = <<-SQL
        PRAGMA table_info("#{table_name}")
      SQL
      table_info = DB[:conn].execute(sql)
      column_names = []
      table_info.each do |row|
        column_names << row["name"]
      end
      column_names.compact
    end

    def initialize(options={})
      options.each do |property, value|
        self.send("#{property}=", value)
      end
    end

    def table_name_for_insert
      self.class.table_name
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
      sql = <<-SQL
        INSERT INTO #{table_name_for_insert}
        (#{col_names_for_insert})
        VALUES (#{values_for_insert})
      SQL
      DB[:conn].execute(sql)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
    end

    def self.find_by_name(name)
      sql = "SELECT * FROM #{table_name} WHERE name = '#{name}'"
      DB[:conn].execute(sql)
    end

    def self.find_by(attribute)
      new_attribute = attribute.collect do |k,v|
        array = []
        array << k.to_s
        end.flatten[0]
      if self.column_names.include?(new_attribute)
        sql = "SELECT * FROM #{table_name} WHERE #{new_attribute} = ?"
        #binding.pry
        DB[:conn].execute(sql, attribute[new_attribute.to_sym])
      end
    end
end
