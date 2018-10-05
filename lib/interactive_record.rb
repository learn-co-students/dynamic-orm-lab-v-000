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

  def values_for_insert #instance method on the student object
    values = []
    self.class.column_names.each do |col_name|
      values << "'#{send(col_name)}'" unless send(col_name).nil?
    end
    values.join(", ") #returns string for the values instead of an array
  end

  def col_names_for_insert
    self.class.column_names.delete_if {|col| col == "id"}.join(", ")
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM #{self.table_name} WHERE name = '#{name}'"
    DB[:conn].execute(sql)
  end

  def self.find_by(anyattribute) #passes in a hash
  #binding.pry
    #anyattribute = {:name=>"Susan"} (for this spec) need to find the matching row in the db.
    key = anyattribute.keys[0]  #assign local variable 'key' set to the hashes' first index (hash that is passed in) the key here for this instance is :name
    value = anyattribute.values[0] #assign local variable 'value' set to that hashes' second index (the value, i.e. "susan" for this instance)
    keystring = key.to_s #must convert this key local variable into a string (instead of :name (symbol) need to turn it into a string to be utilized in the string sql call!!
    sql = "SELECT * FROM #{table_name} WHERE #{keystring} = ?" #search self (in this case, student class is the table_name, and look for WHERE the keystring ("name") equals itself (?).
    DB[:conn].execute(sql, value)
  end

end
