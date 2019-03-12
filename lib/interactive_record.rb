require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord
  attr_accessor :id
  
  def self.table_name 
    self.to_s.downcase.pluralize
  end
  
  def self.column_names
    DB[:conn].results_as_hash = true 
    sql = "pragma table_info('#{table_name}')"
    table_data = DB[:conn].execute(sql)
    column_names = []
    table_data.each do |row|
      column_names << row["name"]
    end
    column_names.compact
  end
  
  def initialize(info = {})
    info.each do |key, value|
      self.send("#{key}=", value)
    end
  end
  
  def table_name_for_insert 
    self.class.table_name
  end

  def col_names_for_insert
    self.class.column_names.delete_if do |col|
      col == "id"
    end.join(", ")
  end
  
  def values_for_insert
    values = []
    self.class.column_names.each do |col_name|
      values << "'#{send(col_name)}'" unless 
      send(col_name).nil?
    end
    values.join(", ")
  end 
  
  def save
    sql = "INSERT INTO #{table_name_for_insert} 
    (#{col_names_for_insert}) 
    VALUES (#{values_for_insert})"
    
    DB[:conn].execute(sql)
    @id = DB[:conn].execute("SELECT * FROM #{table_name_for_insert} WHERE id = 1")[0][0]
  end
  
end