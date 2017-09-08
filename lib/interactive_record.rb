require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord
    
  
  def initialize(attributes = {})
      attributes.each do |k, v|
          self.send("#{k}=", v)
          end# of do 
  end# of initialize      
    
    
  def self.table_name
    self.to_s.downcase.pluralize
  end# of self.table_name
  
  
  def self.column_names
     DB[:conn].results_as_hash = true 
     sql = "PRAGMA table_info('#{table_name}')"
     table_info = DB[:conn].execute(sql)
     column_names = []
     table_info.each do |column|
         column_names << column["name"]
     end# of do
     column_names.compact
  end# of self.column_names 
  
   
  def table_name_for_insert
      self.class.to_s.downcase.pluralize 
  end# of table_name_for_insert
   
  
  def col_names_for_insert
      self.class.column_names.delete_if {|col| col == "id"}.join(", ")
  end# of col_names_for_insert
  
  
  def values_for_insert
      values = []
      self.class.column_names.each do |col_name|
          values << "'#{send(col_name)}'" unless send(col_name).nil?
      end# of do
      values.join(", ")
  end# of values_for_insert
  
  
  def save
      sql = <<-SQL 
      INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})
      SQL
      
      DB[:conn].execute(sql)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  end# of save
  
  
  def self.find_by_name(name)
      sql = "SELECT * FROM #{self.table_name} WHERE name = '#{name}'"
      DB[:conn].execute(sql)
  end# of self.find_by_name
  
  
  def self.find_by(hash)
     sql = "SELECT * FROM #{self.table_name} WHERE #{hash.keys.first.to_s} = '#{hash.values.join}'"
     DB[:conn].execute(sql) 
  end# of self.find_by 
  
  
end# of class 