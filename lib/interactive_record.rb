require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'pry'

class InteractiveRecord
  
    def self.table_name 
        self.to_s.downcase.pluralize
    end 

    def self.column_names
        DB[:conn].results_as_hash = true 
        sql = "PRAGMA table_info (#{table_name});"

        table_info = DB[:conn].execute(sql)

        table_info.map{|column|column["name"]}
        #returns array of attribute names ["id", "names", "grade"]
    end 

    def initialize(options={})
        options.each{|attr_name, value| self.send("#{attr_name}=",value)}
    end 
            
    def table_name_for_insert
        self.class.table_name 
    end
 
    def col_names_for_insert
        col_array = self.class.column_names.delete_if{|col| col == "id"}
        col_array.join(", ")
        #i want "name, grade"
    end 

    def values_for_insert
        values = []
        self.class.column_names.each do | col_name |
            values << "'#{send(col_name)}'" unless send(col_name).nil?
        end 
        values.join(", ")
        #i want "'Sam', '11'"
    end 
    
    def save
        sql ="INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert});"

        DB[:conn].execute(sql)
        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
    end 

    def self.find_by_name(name) 
        sql = "SELECT * FROM #{self.table_name} WHERE name = ?;"
        DB[:conn].execute(sql,name)
    end 

    def self.find_by(attribute) 
        sql = "SELECT * from #{self.table_name} WHERE #{attribute.keys.join} = '#{attribute.values.join}';"
        DB[:conn].execute(sql)
    end 

    
end