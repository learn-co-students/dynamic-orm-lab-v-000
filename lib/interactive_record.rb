require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord

  def self.table_name
    self.to_s.downcase.pluralize
  end

  # --get column names
  def self.column_names
    DB[:conn].results_as_hash = true
    sql = "PRAGMA table_info('#{table_name}')"

    table_info = DB[:conn].execute(sql)
    column_names = []

    table_info.each do |column|
      column_names << column["name"]
    end

    column_names.compact
  end

  # --create attr_accessors for each column name
  self.column_names.each do |col_name|
   attr_accessor col_name.to_sym
  end

  def initialize(options={})
    # --invoking a method via the #send method
    options.each do |property, value|
      self.send("#{property}=", value)
    end
  end

  # --return the table name when called on an instance of Student
  # --get the table names to use as an abstract in the save method
  def table_name_for_insert
    self.class.table_name
  end

  # --return the column names when called on an instance of Student
  # --get the table names to use as an abstract in the save method
  def col_names_for_insert
    self.class.column_names.delete_if { |col| col == "id" }.join(", ")
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

  def self.find_by(hash)
    key_of = nil
    value = nil
    hash.each do |key,val|
      key_of = key
      value = val
    end
    sql = "SELECT * FROM #{self.table_name} WHERE #{key_of} = '#{value}'"
    DB[:conn].execute(sql)
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM #{self.table_name} WHERE name = '#{name}'"
    DB[:conn].execute(sql)
  end

end
