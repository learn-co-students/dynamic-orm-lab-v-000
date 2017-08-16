require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord


  def self.table_name
    #returns name of class as lowercase and pluralized
    self.to_s.downcase.pluralize
  end

  def self.column_names
    #returns all col names from table

    sql = "PRAGMA table_info('#{table_name}')"

    table_info = DB[:conn].execute(sql)
    column_names = []

    table_info.each do |column|
      column_names << column["name"]
    end

    column_names.compact
  end

  def initialize(options={})
    #allows for initializing with hash and proper attr_accessor names as keys
    options.each do |property, value|
      self.send("#{property}=", value)
    end
  end

  def table_name_for_insert
    #reaches outside of the object to get the table name from the class
    self.class.table_name
  end

  def col_names_for_insert
    #returns string of col names for SQL insert
    self.class.column_names.delete_if {|col| col == "id"}.join(", ")
  end

  def values_for_insert
    #returns string of value for SQL insert
    values = []
    self.class.column_names.each do |col_name|
      values << "'#{send(col_name)}'" unless send(col_name).nil?
    end
    values.join(", ")
  end

  def save
    #object saved using values dynamically
    sql = "INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})"

    DB[:conn].execute(sql)

    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  end

  def self.find_by_name(name)
    find_by({name:name})
  end

  def self.find_by(options={})
    #returns values based on string input of col
    sql = "SELECT * FROM #{self.table_name} WHERE #{options.keys[0].to_s} = '#{options.values[0].to_s}'"
    DB[:conn].execute(sql)
  end


end
