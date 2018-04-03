require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord

  def self.table_name
    self.to_s.downcase.pluralize
  end

  def self.column_names
    DB[:conn].results_as_hash = true

    sql = "pragma table_info('#{table_name}')" #access the name of the tabe we're querying

    table_info = DB[:conn].execute(sql)
    column_names = [] #set to empty array
    table_info.each do |column| #iterate to collect only the name of the each column
    column_names << column["name"] #shovel collection of column names we just collected into column_names array
  end
    column_names.compact
  end

  self.column_names.each do |col_name| #iterating over the colummn names and set an attr_accessor for each one and convert the column name string into a symbol.
    attr_accessor col_name.to_sym
  end

  def initialize(options={})
    options.each do |property, value|
      self.send("#{property}=", value) #metaprogram to interpolate the name of each hash key as a method that we set equal to that key's value.
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

  def col_names_for_insert
    self.class.column_names.delete_if {|col| col == "id"}.join(", ")
  end

  def values_for_insert
    values = []
    self.class.column_names.each do |col_name|
      values << "'#{send(col_name)}'" unless send(col_name).nil? #sql expects each column value to be passed in single quotes
    end
    values.join(", ") #joining array into a string
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM #{self.table_name} WHERE name = '#{name}'"
    DB[:conn].execute(sql)
  end #dynamic and abstract af since the method does not reference the table name explicity. will return the table name associated with any given class in our program

  def self.find_by(attribute)
    sql = "SELECT * FROM #{self.table_name} WHERE #{attribute.keys[0].to_s} = '#{attribute.values[0]}'"
    DB[:conn].execute(sql)
  end
end
