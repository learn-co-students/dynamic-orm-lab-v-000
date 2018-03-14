require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord

  #class methods
  def self.table_name
    self.to_s.downcase.pluralize
  end

  def self.column_names
    sql = "PRAGMA table_info('#{table_name}')"
    table_info = DB[:conn].execute(sql)
    column_names = []
    table_info.each do |column|
      column_names << column["name"]
    end
    column_names.compact
  end

  #executes the SQL to find a row by name
  def self.find_by_name(name)
    sql = "SELECT * FROM #{table_name} WHERE name = ?"
    DB[:conn].execute(sql, name)
  end
  
  #executes the SQL to find a row by the attribute passed into the method
  #accounts for when an attribute value is an integer
  def self.find_by(option={})
    sql = "SELECT * FROM #{table_name} WHERE #{option.keys[0].to_s} = '#{option.values[0]}'"
    DB[:conn].execute(sql)
  end

  def initialize(options={})
    options.each do |property, value|
      self.send("#{property}=", value)
    end
  end

  #Instance Methods

  #return the table name when called on an instance of Student
  def table_name_for_insert
    self.class.table_name
  end

  #return the column names when called on an instance of Student
  #does not include an id column
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

  # saves the student to the db
  #sets Studend ID
  def save
    sql = "INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})"

    DB[:conn].execute(sql)

    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  end









end
