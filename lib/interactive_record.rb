require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord

  # creates a downcased, plural table name based on the Class name
  def self.table_name
    self.to_s.downcase.pluralize
  end

  # returns an array of SQL column names
  def self.column_names
    DB[:conn].results_as_hash = true

    sql = "pragma table_info('#{table_name}')"
    table_info = DB[:conn].execute(sql)

    table_info.collect {|row| row["name"]}.compact
  end

  # creates an new instance of a student
  # creates a new student with attributes
  def initialize(options={})
    options.each do |property, value|
      self.send("#{property}=",value)
    end
  end

  # return the table name when called on an instance of Student
  def table_name_for_insert
    self.class.table_name
  end

  # return the column names when called on an instance of Student
  # does not include an id column
  def col_names_for_insert
    self.class.column_names.delete_if {|col_name| col_name == "id"}.join(", ")
  end

  # formats the column names to be used in s SQL statement
  def values_for_insert
    values = self.class.column_names.collect {|col_name| "'#{send(col_name)}'" unless send(col_name).nil?}.compact.join(", ")
  end

  def save
    sql = <<-SQL
      INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})
    SQL
    DB[:conn].execute(sql)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  end

end
