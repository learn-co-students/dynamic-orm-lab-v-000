require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'pry'

class InteractiveRecord

  def initialize(options={}) #default argument is an empty hash. will likely evoke with attr_hash
    #for each attribute|value pair we send the attribute method of the same name and point it to the value
    #this method is equivelent to
    # @id, @breed = id, breed
    options.each do |property, value|
      self.send("#{property}=", value)
    end
  end


  def self.table_name
    self.to_s.downcase.pluralize
  end

  def self.column_names
    #set the db connection to hash (rather than array)
    DB[:conn].results_as_hash = true

    #write a sql statement to pull table info as a bunch of hashes. each representing a row in the table
    sql = "PRAGMA TABLE_INFO('#{table_name}')"
    table_info = DB[:conn].execute(sql)

    #initialize an array to hold column names
    column_names = []

    #iterate over the table hashes that were pulled and extract the name of the column
        table_info.each do |row|
          column_names << row["name"]
        end

        #remove any nils from the array with #compact
        column_names.compact
    end

  def save
    #insert variables and their values into DB with the following SQL statement
    sql = "INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})"
    #execute sql to insert values
    DB[:conn].execute(sql)
    #extract id back from DB and assign to id attribute of ruby object
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  end

  def table_name_for_insert
    #call the class method table_name on an instance by using self.class
    self.class.table_name
  end

  def values_for_insert
    #initialize an array to hold the values we want
    values = []

    #we use the send method and column names(ex name, breed) to craft a string like "Joe, Shepperd" for use in a sql statement
    self.class.column_names.each do |col_name|
      #the send(column_names) interpelates the values recieved fromt he column name
      values << "'#{send(col_name)}'" unless send(col_name).nil?
    end
    values.join(", ")
  end

  def col_names_for_insert
    #aka variable/attributes we want to insert (not their values yet)
    #remember column_names is a class method. must be called with self.class

    col_name = self.class.column_names.delete_if {|col_name| col_name == "id"}.join(", ")
    #binding.pry
  end



  def self.find_by_name(name)
    #seach the db with a sql query to find by name
    sql = "SELECT * FROM #{self.table_name} WHERE name = '#{name}'"
    DB[:conn].execute(sql)
  end

  def self.find_by(attr_hash)
    binding.pry
    if attr_hash[0].class.is_a?(Fixnum)
        sql = "SELECT * FROM (#{self.table_name}) WHERE id = ?"
        one = DB[:conn].execute(sql, attr_hash[:id])
        #binding.pry
    else
      sql = "SELECT * FROM (#{self.table_name}) WHERE name = ?"
      two = DB[:conn].execute(sql, attr_hash[:name])
    end

  end






end
