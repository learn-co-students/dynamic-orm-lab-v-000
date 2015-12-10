require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'pry'

class InteractiveRecord

  def self.table_name
    self.to_s.downcase.pluralize
  end

  def self.column_names
    sql = "PRAGMA table_info ('#{table_name}')"
    table_data = DB[:conn].execute(sql)
    column_names = []
    table_data.each do |row|
      column_names << row["name"]
    end
    column_names.compact
  end

  self.column_names.each do |col_name|
    attr_accessor col_name.to_sym
  end

  def initialize(hash = {})
    hash.each do |var, value|
      self.send("#{var}=",value)
    end
  end

  def table_name_for_insert
    self.class.table_name
  end

  def col_names_for_insert
    self.class.column_names.delete_if{|col| col == "id"}.join(", ")
  end

  def values_for_insert
    values = []
    self.class.column_names.each do |col|
      values << "'#{send(col)}'" unless self.send(col).nil?
    end
    values.join(", ")
  end

  def save
    sql = "INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})"
    DB[:conn].execute(sql)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM #{table_name} WHERE name = ?"
    DB[:conn].execute(sql,name)
  end

  def self.find_by(attribute)
    property = attribute.keys[0].to_s
    property == :grade ? value = attribute[attribute.keys[0]].to_i : value = attribute[attribute.keys[0]]
    sql = "SELECT * FROM #{table_name} WHERE #{property} = '#{value}'"
    DB[:conn].execute(sql)
  end
  
end