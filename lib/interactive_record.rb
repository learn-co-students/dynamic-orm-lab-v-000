require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord
  def initialize(options={})
    options.each do |prop, value|
      self.send("#{prop}=",value)
    end
  end

  def self.table_name
    self.to_s.downcase.pluralize
  end

  def table_name_for_insert
    self.class.table_name
  end

  def self.column_names
    sql = "PRAGMA table_info('#{table_name}')"
    table_info = DB[:conn].execute(sql)
    column_names = []

    table_info.each do |column|
      column_names << column["name"]
    end

    column_names.compact
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM #{table_name} WHERE name = ?"
    DB[:conn].execute(sql, name)
  end

  def self.find_by(option = {})
    sql = "SELECT * FROM #{table_name} WHERE #{option.keys.first.to_s} = '#{option.values.first}'"
    DB[:conn].execute(sql)
  end

  def col_names_for_insert
    self.class.column_names.delete_if {|col| col == "id"}.join(", ")
  end

  def values_for_insert
    values = []

    self.class.column_names.each do |column|
      values << "'#{send(column)}'" unless send(column).nil?
    end
    values.join(", ")
  end

  def save
    sql = "INSERT INTO #{self.class.table_name} (#{col_names_for_insert}) VALUES (#{values_for_insert})"
    DB[:conn].execute(sql)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{self.class.table_name}")[0][0]
    self
  end
end
