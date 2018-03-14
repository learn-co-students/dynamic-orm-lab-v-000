require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord
  
  def initialize(attributes = {})
  	attributes.each do |key, value| 
  		self.send("#{key}=", value)
  	end
  end

  def self.table_name
  	self.to_s.downcase.pluralize
  end

  def self.column_names
  	DB[:conn].results_as_hash = true

  	sql = "PRAGMA table_info(#{table_name})"
  	column_info = DB[:conn].execute(sql)

  	column_values = []
  	column_info.each do |col|
  		column_values << col["name"]
  	end
  	column_values.compact
  end

  def table_name_for_insert
  	self.class.table_name
  end

  def col_names_for_insert
  	self.class.column_names.delete_if {|item| item == "id"}.join(", ")
  end

  def values_for_insert
  	values = [] 
  	self.class.column_names.each do |column_name|
  		values << "'#{self.send(column_name)}'" unless self.send(column_name).nil? #values become ["'element1'", "'element2"]
  	end
  	values.join(", ") #returns - "'element1', 'element2'" -wrapped in single quotes because when you call insert into table the values needs to be comma seperated in quotes
  end #since the sql - call in ruby requires the SQL query to already be wrapped in a string - the internal single quote is needed to pass through values

  def save
  	sql = "INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})"
  	DB[:conn].execute(sql)

  	@id = DB[:conn].execute("SELECT last_insert_rowid()")[0][0]
  end

  def self.find_by_name(name)
  	sql = "SELECT * FROM #{table_name} WHERE name = ?"

  	DB[:conn].execute(sql, name)
  end

  def self.find_by(attribute) #this is a hash key value pair
  	sql = ""
  	key = attribute.keys[0]
  	value = attribute[key]
  	formated_value = value.class == Fixnum ? value : "'#{value}'" #if value is a string - wrap it in single quotes so when it passes through sql query it will look for 'string'
  	#if '' is not present - it will assume it is looking for a column
  	sql = "SELECT * FROM #{table_name} WHERE #{key} = #{formated_value}"
  	DB[:conn].execute(sql)
  end

end