require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'pry'

class InteractiveRecord
  
  def initialize(args = {})
     args.each do |key, value|
         self.send("#{key}=", value)
     end
  end
  
  def self.table_name
     self.to_s.downcase.pluralize 
  end
  
  def self.column_names
      DB[:conn].results_as_hash = true
      sql = "PRAGMA table_info('#{table_name}')"
      
      table_info = DB[:conn].execute(sql)
      col_names = table_info.map {|row| row["name"]}.compact
  end
  
  def table_name_for_insert
      self.class.table_name
  end
  
  def col_names_for_insert
     columns = self.class.column_names 
     columns.delete_if {|col| col == "id"}
     columns.join(", ")
  end
  
  def values_for_insert
     values = self.class.column_names.map do |col|
        "'#{send(col)}'" unless send(col).nil?
     end.compact
     values.join(", ")
  end
  
  def save
    sql = "INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})"
    DB[:conn].execute(sql)
    
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  end
  
  def self.find_by_name(name)
    sql = "SELECT * FROM #{self.table_name} WHERE name = '#{name}'"

    DB[:conn].execute(sql)
  end
  
  def self.find_by(attribute)
    sql = "SELECT * FROM #{self.table_name} WHERE #{attribute.keys.first} = '#{attribute.values.first}'"
    DB[:conn].execute(sql)
  end
  
end