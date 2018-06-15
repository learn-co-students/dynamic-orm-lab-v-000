require_relative "../config/environment.rb"
require 'active_support/inflector'

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
  
end