require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord

  def initialize(options={})
    options.each do |key, value|
      self.send("#{key}=", value)
    end
  end

  def self.table_name
    self.to_s.downcase.pluralize
  end

  def table_name_for_insert
    self.class.table_name
  end

  def self.column_names
    col_names = []
    sql = "PRAGMA table_info ('#{self.table_name}')"
    table_info = DB[:conn].execute(sql)
    table_info.each do |column|
      col_names << column["name"]
    end
    col_names.compact
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
    sql= "INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})"
    DB[:conn].execute(sql)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  end

  def self.find_by_name (name)
    sql = "SELECT * FROM #{self.table_name} WHERE name = '#{name}'"
    DB[:conn].execute(sql)
  end

  def self.find_by (col_name = {})
    sql = nil
    col_name.each do |key,value|
      sql = "SELECT * FROM #{self.table_name} WHERE #{key} = '#{value}'"
    end
    DB[:conn].execute(sql)

  end

end
