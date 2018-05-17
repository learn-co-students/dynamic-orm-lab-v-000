 require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord
  
  def self.table_name
    self.to_s.downcase.pluralize
  end 
  
  def self.column_names
    DB[:conn].results_as_hash = true 
    
    sql = "PRAGMA table_info(#{table_name});"
    
    columns = []
    DB[:conn].execute(sql).each do |col|
      columns << col["name"]
    end 
    columns.compact
  end 
  
  def initialize(options={})
    options.each{ |k ,v| send("#{k}=", v) }
  end 
  
  def table_name_for_insert
    self.class.table_name
  end 
  
  def col_names_for_insert
    self.class.column_names.delete_if{ |col| col == "id" }.join(', ')
  end 
  
  def values_for_insert
    Array.new.tap do |values|
      self.class.column_names.each do |col|
        values << "'#{send(col)}'" unless send(col).nil?
      end
    end.join(', ')  
  end 
  
  def save
    sql = "INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})"
    
    DB[:conn].execute(sql)
    
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  end 
  
  def self.find_by_name(name)
    DB[:conn].results_as_hash = true 
    
    sql = "SELECT * FROM #{table_name} WHERE name = ?"
    
    DB[:conn].execute(sql, name)
  end 
  
  def self.find_by(attr_hash)
    #executes the SQL to find a row by the attribute passed into the method
    DB[:conn].results_as_hash = true
    
    col = attr_hash.keys[0].to_s 
    val = attr_hash.values[0]
    
    DB[:conn].execute("SELECT * FROM #{table_name} WHERE #{col} = ?", val)
  end 
  
end