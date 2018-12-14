require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'pry'

class InteractiveRecord
  def self.table_name
    self.to_s.downcase.pluralize
  end
  
  def self.column_names
    sql = "PRAGMA table_info(#{self.table_name})"
    
    table_info = DB[:conn].execute(sql)
    table_info.collect {|table_column| table_column["name"]}.compact
  end
  
  def initialize(attributes = {})
    attributes.each {|key, value| self.send("#{key}=", value)}
  end
  
  def table_name_for_insert 
    self.class.table_name
  end
  
  def col_names_for_insert
    delete_column_name("id").join(", ")
  end
  
  def delete_column_name(name)
    self.class.column_names.delete_if {|col_name| col_name == name}
  end
  
  def values_for_insert
    values = self.class.column_names.collect do |col_name| 
      "'#{self.send(col_name)}'" unless self.send(col_name).nil?
    end
    
    values.compact.join(", ")
  end
  
  def save
    columns_and_values = col_names_for_insert.split(", ").collect do |column| 
      [column, self.send(column)]
    end
    
    first_column_and_value = columns_and_values.shift
    first_column = first_column_and_value[0]
    first_value = first_column_and_value[1]
    
    sql_one = "INSERT INTO #{table_name_for_insert} (#{first_column}) VALUES (?)"
    DB[:conn].execute(sql_one, first_value)
    
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
    
    columns_and_values.each do |column_and_value|
      sql_two = "INSERT INTO #{table_name_for_insert} (#{column_and_value[0]}) VALUES (?) WHERE id = (#{self.id})"
      
      DB[:conn].execute(sql_two, column_and_value[1])
    end
    
    # The following code won't work, because it creates TWO rows in the students table, setting grade = nil each time. But how do I sanitize the values? (It's not required; I just want to know.)
    #column_values_hash.each do |key, value|
    #  sql = "INSERT INTO #{table_name_for_insert} (#{key}) VALUES (?)"
    #  DB[:conn].execute(sql, value)
    #end
    
    #sql = "INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (?)"
    #DB[:conn].execute(sql, values_for_insert)
  end
  
  #def column_values_hash
  #  hash = {}
  #  columns = col_names_for_insert.split(", ")
  #  columns.each {|column| hash[column] = self.send(column)}
  #  hash
  #end
  
  
end
