require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'pry'

class InteractiveRecord

  def self.table_name 
    #creats a downcased plural table name based on Class name
    self.to_s.downcase.pluralize 
  end

  def self.column_names 
    # returns an array of SQL column names
    #hash of columns names
    #return them as a an array of strings
    
    DB[:conn].results_as_hash = true
    
    #give you the hash of info
    sql = "PRAGMA table_info('#{table_name}')"
    
    table_info = DB[:conn].execute(sql) 
    
    # creates attr_accessors for each column name
    column_names = []
     
    table_info.each do |row| #iterate over the array of hashes
      column_names << row["name"] #this gives you the value for the key "name"
    end
    column_names.compact #to get rid of any nulls
  end
  
  #creates new student with attributes
  def initialize(objects = {}) #pass in a hash 
    objects.each do |key,value|
      self.send("#{key}=",value)
    end
  end  

  # save - INSERT INTO students (name, grade) VALUES (x,y)
  def save
    sql = "INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})"
    DB[:conn].execute(sql)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  end
  
  def table_name_for_insert 
    # returns the table name when called on an instance of Student
    self.class.table_name
  end
  
  def col_names_for_insert 
    # return column names when called on an instance of Student does not include id column 
    #returns it as a string ready to be inserted into a sql statement
    self.class.column_names.delete_if {|col| col == "id"}.join(", ")
  end 
  
  def values_for_insert 
    #formats the column names to be used in SQL statement
    #use the column_names array, iterate over it to get the attribute names
    #and then user the attribute = method with send to assign the value
    values = []
    self.class.column_names.each do |col_name|
      #get the value for each attribute name
      values << "'#{send(col_name)}'" unless send(col_name).nil?
    end  
    values.join(", ")  
  end
  
  def self.find_by_name(name)
    sql = "SELECT * FROM #{self.table_name} WHERE name = '#{name}'"
    DB[:conn].execute(sql)
  end
  
  def self.find_by (attribute)
    #executes the SQL to find a row by the attribute passed into the method
    #WHERE name = ? OR grade = ? OR id = ?
    #attribute is a hash, so it has a key/value pair
    
    column_name = attribute.keys[0].to_s
    value_name = attribute.values[0]

    sql = <<-SQL
      SELECT * FROM #{self.table_name}
      WHERE #{column_name} = #{value}
      SQL

    DB[:conn].execute(sql, value_name);
  end
  
end
