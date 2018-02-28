require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'pry'

class InteractiveRecord

  def self.table_name
    # turns class name into a lowercase, pluralized table name
    self.to_s.downcase.pluralize
  end

  def self.column_names
    # provides a table info as a hash
    # pulls just the "name" properties to get the name of each column
    # iterates over the column names array, turning each into an attr_accessor/symbol
    sql = "PRAGMA table_info('#{self.table_name}')"
    table_info = DB[:conn].execute(sql)

    column_names = []
    table_info.each do |col|
      column_names << col["name"]
    end
    column_names.compact
    column_names.each do |col_name|
      attr_accessor col_name.to_sym
    end
  end

  def initialize(options = {})
    # creates an instance of a class
    # uses a provided hash to assign attr_accessors and their values to an object
    options.each do |property, value|
      self.send("#{property}=", value)
    end
  end

  # PREPARING TABLES AND COLUMNS FOR SQL .INSERT INTO/#save

  def table_name_for_insert
    self.class.table_name
  end

  def col_names_for_insert
    # need to remove the id attr prior to prepping for INSERT INTO
    col_name_array = self.class.column_names.delete_if{|col_name| col_name == "id"}
    # turn array of column names into a CSV file
    col_name_array.join(", ")
  end

  def values_for_insert
    # first step = preparing to collect the values in an col_name_array
    values = []
    # the attr_accessors have already been assigned, so use #send to call: ex. self.name, self.breed etc.
    self.class.column_names.each do |col_name|
      values << "'#{send(col_name)}'" unless send(col_name).nil?
    end
    values.join(", ")
  end

  # Dynamic #save == SQL .INSERT

  def save
    sql = <<-SQL
      INSERT INTO #{table_name_for_insert} (#{col_names_for_insert})
      VALUES (#{values_for_insert})
    SQL

    DB[:conn].execute(sql)
    # need to assign .id here because does not have id when instantiated, but now has one via its database
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM #{self.table_name} WHERE name = ?"
    DB[:conn].execute(sql, name)
  end

  def self.find_by(hash)
    # get the first key and value from a hash: key, value = hash.first || key = hash.keys[0], value = hash.values[0]
    attribute_key = hash.keys.first
    value = hash.values.first
    # Is the value an Integer or String?
    # Under effectively no circumstances will you ever ask for an object's class and be told that it is an Integer - Use Fixnum
    format_value = value.class == Fixnum ? value : "'#{value}'"
    sql = "SELECT * FROM #{self.table_name} WHERE #{attribute_key} = #{format_value}"
    DB[:conn].execute(sql)
  end
end























# passes one part of find_by active_support

# def self.find_by(hash) # {name: "Susan", grade: 10}
#   attribute = hash.keys.to_s
#
#   sql = "SELECT * FROM #{self.table_name} WHERE ? = ?"
#   DB[:conn].execute(sql, attribute, attribute)
#   binding.pry
# end



# def self.find_by(hash) # {name: "Susan", grade: 10}
#   # executes the SQL to find a row by the attribute passed into the method
#   sql = "SELECT * FROM #{self.table_name} WHERE ? = ?"
#
#   attribute = hash.to_a.flatten[0].to_s
#
#   DB[:conn].execute(sql, attribute, attribute)
#   # pass part of test but return all students when attribute = attribute ????
#   # binding.pry
# end




#### another try

# array = hash.keys.collect! { |k| k.to_s }
#
# array.each do
