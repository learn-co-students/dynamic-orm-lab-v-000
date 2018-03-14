require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord

  #find by
  def self.find_by(value)
    sql = "SELECT * FROM #{self.table_name} WHERE #{value.keys[0]} = '#{value.values[0]}'"
    DB[:conn].execute(sql)
  end

  #table name for insert
  def table_name_for_insert
    self.class.table_name
  end

  #save
  def save
    sql = "INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})"
    DB[:conn].execute(sql)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  end

  #values for insert
  def values_for_insert
    values = []
    self.class.column_names.each do |col_name|
      values << "'#{send(col_name)}'" unless send(col_name).nil?
    end
    values.join(", ")
  end

  #initialize
  def initialize(options={})
    options.each do |property, value|
      self.send("#{property}=", value)
    end
  end

  #col names for insert
  def col_names_for_insert
    self.class.column_names.delete_if { |col| col == "id"}.join(", ")
  end

  #column names
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

  #table name
  def self.table_name
    self.to_s.downcase.pluralize
  end

  #find by name
  def self.find_by_name(name)
    sql = "SELECT * FROM #{self.table_name} WHERE name = '#{name}'"
    DB[:conn].execute(sql)
  end

end
