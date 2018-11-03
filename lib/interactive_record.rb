require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'pry'
class InteractiveRecord
  
  def self.table_name #method returns a name for table
    self.to_s.downcase.pluralize #turns Class name into a string, downcase, and pluralize it
  end 
  
  def self.column_names #returns an array of SQL column names
    DB[:conn].results_as_hash = true #.results_as_hash is part of a ruby gem
    #helps to get return values in hash instead of an array
 
    sql = "PRAGMA table_info('#{table_name}')" #SQL query for table names
 
    table_info = DB[:conn].execute(sql)
    column_names = []
 
    table_info.each do |column|
      column_names << column["name"] #each hash has a name key that points to a value of the column name
    end
    column_names.compact #.compact gets rid of any nil values
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
  
  
  #uses methods previously written like table_name_for_insert, for table column and values
  def save
    sql = "INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})"
 
    DB[:conn].execute(sql)
 
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  end
  
  def self.find_by_name(name)
    sql = "SELECT * FROM #{self.table_name} WHERE name = '#{name}'" 
    DB[:conn].execute(sql)
  end
  
  def self.find_by(hash)
    key = hash.keys.first
    value = hash.values.first
    
    sql =<<-SQL
      SELECT * FROM #{self.table_name}
      WHERE #{key} = "#{value}"
      LIMIT 1
    SQL
    DB[:conn].execute(sql)
    #binding.pry
    
  end
end