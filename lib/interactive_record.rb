require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'pry'

class InteractiveRecord

  def self.table_name
    self.to_s.downcase.pluralize
  end

  def self.column_names
    DB[:conn].results_as_hash = true 
    # results_as_hash is A boolean that indicates whether rows in result sets should be returned as hashes or not. 
    # By default, rows are returned as arrays
    sql = "PRAGMA table_info('#{table_name}')"
    # PRAGMA schema.table_info(table-name);
    # ususally, returns one row for each column in the named table, 
    # in this case returns an array of hashes, where each hash has the info on one column
    table_info = DB[:conn].execute(sql)
    # sets var table_name equal to the hash returned by executing the SQL stmnt
    column_names = []

    table_info.each do |col|
      column_names << col["name"]
    end
    # iterate over the table_info hash
    # and collect the value each hash's "name" key points at (the names of the columns)
    column_names.compact 
    # .compact gets rid of any nil values
    # #column_names returns an array of strings, column names
  end

  def table_name_for_insert
    self.class.table_name
  end

  def col_names_for_insert
    self.class.column_names.delete_if {|col|
      col == "id"}.join(", ")
    # self.class.column_names returns an array of column names
    # .delete_if {|col| col == "id"} removes the id column b/c when we insert a row we don't add an id attr
    # .join(", ") converts or array to a string and places ", " between the array elements
    # .join(", ") converts the arrary into the string we want for our instert stmnt
  end

  def values_for_insert
    values = []
    self.class.column_names.each do |col_name|
      values << "'#{send(col_name)}'" unless send(col_name).nil?
    end
    values.join(", ")
    # iterate over result of #column_names & use #send to call reader methods on an instance and grab attr values to insert
    # so many quotes! "" b/c ultimately we're trying to craft a string of SQL
    # each value gets '' b/c our SQL stmnt ought to look like VALUES 'value1', 'value2' 
    # values is an array, so we use .join to combine the elements into one string
  end

  def save
    sql = "INSERT INTO #{table_name_for_insert}(#{col_names_for_insert}) VALUES (#{values_for_insert})"
    DB[:conn].execute(sql)
    # put all the for_insert methods to work to insert a row
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
    # grab the newly set id value
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM #{self.table_name} WHERE name = '#{name}'"
    DB[:conn].execute(sql)
    # select the row from this table where name matches argument
  end

  def self.find_by(**keyword_arg)
    arr = keyword_arg.to_a
    sql = "SELECT * FROM #{self.table_name} WHERE #{arr[0][0].to_s} = '#{arr[0][1]}'"
    DB[:conn].execute(sql)
  end

  
end