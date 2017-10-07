require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord

  def self.table_name
    self.to_s.downcase.pluralize
  end

  def self.column_names
    # accessing the DB and returns the results as a hash
    DB[:conn].results_as_hash = true
    # using PRAGMA tool to gather the table info and return the table name into an array
    sql = "PRAGMA table_info('#{table_name}')"

    table_info = DB[:conn].execute(sql)
    column_names = []

# iterating over the column names to collect one name of each column
    table_info.each do |column|
      column_names << column["name"]
    end
    column_names.compact
  end

  def initialize(options={})
    options.each do |property, value|
      self.send("#{property}=", value)
    end
  end

# this is an instance method; self will refer to the instance of the class, not the class itself.
  def table_name_for_insert
    # we are using a class method inside the instance menthod
    self.class.table_name
  end

# returns the column names without an id
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

  def save
    sql = "INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})"

    DB[:conn].execute(sql)

    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM #{table_name} WHERE name = '#{name}' "
    DB[:conn].execute(sql)
  end

  def self.find_by(attribute_hash)
    # executes the SQL to find a row by the attribute passed into the method
    value = attribute_hash.values.first
    # fixnum accounts for when an attribute is a number/integer 
    formatted_value = value.class == Fixnum ? value : "'#{value}'"
    sql = "SELECT * FROM #{self.table_name} WHERE #{attribute_hash.keys.first} = #{formatted_value}"

    DB[:conn].execute(sql)
  end

end
