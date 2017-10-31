require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'pry'

class InteractiveRecord

  def self.table_name
    self.to_s.downcase.pluralize
  end

  def self.column_names
    DB[:conn].results_as_hash = true
    table_info = DB[:conn].execute("PRAGMA table_info('#{table_name}')")
    column_names = table_info.collect do |column|
      column["name"]
    end
    column_names.compact
  end

  def initialize(options = {})
    options.each do |property, value|
      self.send("#{property}=", value)
    end
  end

  def table_name_for_insert
    self.class.table_name
  end

  def col_names_for_insert
    self.class.column_names.delete_if {|col| col == "id"}.join(", ")
  end

  def values_for_insert
    self.class.column_names.collect do |col_name|
      "'#{send(col_name)}'" unless send(col_name).nil?
    end.compact.join(", ")
  end

  def save
    sql = "INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})"
    DB[:conn].execute(sql)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM #{self.table_name} WHERE name = ?"
    DB[:conn].execute(sql, name)
  end

  def self.find_by(attribute)
    attr_name = attribute.map(&:first).join.to_s
    attr_value = attribute.map(&:last).join
    sql = "SELECT * FROM #{self.table_name} WHERE #{attr_name} = ?"
    DB[:conn].execute(sql, attr_value)
    #need attr_value in execute because we want the sql to read like this
    #"SELECT * FROM #{self.table_name} WHERE name = 'Susan'"
    #if attr_value was directly in string interpolation we would get
    ##"SELECT * FROM #{self.table_name} WHERE name = Susan"
  end

end# Class closer
