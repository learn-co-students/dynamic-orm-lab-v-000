require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord
  
  #instance method - constructor with an options hash, defaulting to an empty hash. From that hash, uses self.send to set instance variables
  def initialize(options = {})
    options.each do |property, value|
      self.send("#{property}=", value)
    end
  end
  
  #class method - uses the name of the class, turns it into a string, downcases it, and uses inflector pluralize - so "Student" class returns a table name of "students"
  def self.table_name
    self.to_s.downcase.pluralize
  end
  
  #class method - return column names from the databse
  def self.column_names
    DB[:conn].results_as_hash = true #sets the connection to return results in the form of a hash rather than a nested array, so {id => 1, grade => "B"} as opposed to [[1, "B"]]

    sql = "pragma table_info('#{table_name}')" #gets all the table information, calling the table_name method to get the table name

    table_info = DB[:conn].execute(sql) #executes previous sql query
    column_names = []
    table_info.each do |row| #iterates through the hash and for each item, retrieves only the name (there's other stuff returned using pragma, but the column name is all we want)
      column_names << row["name"]
    end
    column_names.compact #gets rid of any nil values just in case with .compact and returns the array
  end
  
  #instance method - gets table name, col names, and values, and inserts into database via SQL query
  def save
    sql = "INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})"
    DB[:conn].execute(sql)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0] #retrieves id from database after inserting into it
  end
  
  #instance method - shorthand method for invoking the class method to get the table name
  def table_name_for_insert
    self.class.table_name
  end

  #instance method - gets the column names via the class method and uses them via the send method to actually get those associate values
  #so gets id, name, grade column names, and uses send() to get 1, "Bob", 10, and puts them into an array and joins them into a string so you can then insert into the database via SQL query via the save method
  def values_for_insert
    values = []
    self.class.column_names.each do |col_name|
      values << "'#{send(col_name)}'" unless send(col_name).nil?
    end
    values.join(", ")
  end

  #instance method - gets the column names via class method, deletes id, and joins into a string that can be used for an SQL query
  def col_names_for_insert
    self.class.column_names.delete_if {|col| col == "id"}.join(", ")
  end

  #class method - uses SQL query to find a row in the databse by name
  def self.find_by_name(name)
    sql = "SELECT * FROM #{self.table_name} WHERE name = '#{name}'"
    DB[:conn].execute(sql)
  end

  #class method - uses SQL query to find a row in the database by whatever attributes are passed to it in a hash e.g. {name: "Bob"} or {grade: 10}
  def self.find_by(attribute_hash)
    sql = "SELECT * FROM #{self.table_name} WHERE #{attribute_hash.keys.first} = '#{attribute_hash.values.first}'"
    DB[:conn].execute(sql)
  end
end