require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'pry'

class InteractiveRecord

  def self.table_name
    self.to_s.downcase.pluralize
  end

  def self.column_names
    DB[:conn].results_as_hash = true

    sql = "pragma table_info('#{table_name}')"

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

  def save
    sql = "INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})"
    DB[:conn].execute(sql)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  end

  def table_name_for_insert
    self.class.table_name
  end

  def values_for_insert
    values = []
    self.class.column_names.each do |col_name|
      values << "'#{send(col_name)}'" unless send(col_name).nil?
    end
    values.join(", ")
  end

  def col_names_for_insert
    self.class.column_names.delete_if {|col| col == "id"}.join(", ")
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM #{self.table_name} WHERE name = ?"
    DB[:conn].execute(sql, name)
  end
  
  binding.pry

  def self.find_by(attribute:)
    column = attribute.fetch(key_name)
    table = self.table_name
    sql = "SELECT * FROM ? WHERE ? = ?"
    DB[:conn].execute(sql, table, column, attribute)
  end
end
    
    
    
    
    
    #if attribute.class = Integer 
      #sql = "SELECT * FROM #{self.table_name} WHERE #{attribute} = ?"
    #DB[:conn].execute(sql, attribute)
    #if attribute.class 
    #sql = "SELECT * FROM #{self.table_name} WHERE ? = ?"
    #DB[:conn].execute(sql, attribute)
    
    
    
    #temp_array = []
    #self.column_names.each do |column|
    #if attribute.fetch('key', nil) == column
      #temp_array << column 
      #end 
    #table = self.class.table_name
    #column = attribute.fetch('key', nil)
    #sql = "SELECT * FROM ? WHERE ? = ?"
    #DB[:conn].execute(sql, table, column, attribute.value)
 