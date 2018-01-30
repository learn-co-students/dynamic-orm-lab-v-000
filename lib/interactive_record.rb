require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'pry'

class InteractiveRecord
    
    def self.table_name
        self.to_s.downcase.pluralize
    end
    
    def self.column_names
        sql = <<-SQL
        PRAGMA table_info(#{table_name})
        SQL
        
        column_names = []
        
        DB[:conn].execute(sql).each do |col|
            column_names << col["name"]
        end
        
        column_names
    end
    
    def initialize(attributes={})
        attributes.each do |property, value|
            self.send("#{property}=", value)
        end
    end

    def table_name_for_insert
        self.class.table_name
    end
    
    def col_names_for_insert
        self.class.column_names.delete_if {|col| col == "id"}.join(", ")
        # RETURN: "name, grade"
    end
    
    def values_for_insert
        values = []
        
        self.class.column_names.each do |col| 
            values << "'#{send(col)}'" unless send(col).nil?
        end
        
        values.join(", ")
    end
    
    def save
        # "INSERT INTO students (name, grade) VALUES 'Hello', '25';
        sql = "INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert});"

        DB[:conn].execute(sql)

        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
    end

    def self.find_by_name(name)
        sql = "SELECT * FROM #{self.table_name} WHERE name = '#{name}';"
        row = DB[:conn].execute(sql)
    end

    def self.find_by(hash)
        sql = ""
        hash.each do |key, value|
            if value.is_a? String
                value = "'#{value}'"
            end
            sql = "SELECT * FROM #{self.table_name} WHERE #{key} = #{value}"
        end
        row = DB[:conn].execute(sql)
    end

end