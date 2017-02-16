require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord

  def initialize(options={})
    options.each do |property, value|  #for each key:value pair in options
      self.send("#{property}=", value) #set property equal to value for this instance
    end
  end

  def self.table_name
    self.to_s.downcase.pluralize #take self, turn to string, downcase, plural with inflector
  end

  def self.column_names
    DB[:conn].results_as_hash = true

    sql = "PRAGMA table_info('#{table_name}')" #this SQL command returns the table info as an array
    table_info = DB[:conn].execute(sql) #execute line 1
    column_names = [] #we store each column name here

    table_info.each do |column|  #iterate over each 'column' of data in the PRAGMA return batch
      column_names << column["name"]  #take the "name" key of each column of data
    end
    column_names.compact #get rid of nil values just in case
  end

  def table_name_for_insert
    self.class.table_name
  end

  def col_names_for_insert
    self.class.column_names.delete_if {|col_name| col_name == "id"}.join(", ")
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
    sql = "SELECT * FROM #{self.table_name} WHERE name = '#{name}'"
    DB[:conn].execute(sql)
  end

  def self.find_by(attribute={})
    attribute.map do |key, value|
      sql = "SELECT * FROM #{self.table_name} WHERE #{key} = '#{value}'"
      DB[:conn].execute(sql)
    end.flatten
  end

end
