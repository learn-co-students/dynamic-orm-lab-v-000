require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord

  def self.table_name
    self.to_s.downcase.pluralize
  end

  def self.column_names
    DB[:conn].results_as_hash = true
    sql = "PRAGMA table_info(?)"

    columns_query = DB[:conn].execute(sql, self.table_name)
    columns_compiler = []
    columns_query.each do |column|
    columns_compiler << column["name"]
    end
    columns_compiler.compact
  end

  def initialize(attributes = {})
    attributes.each do |key, value|
      self.send("#{key}=", value)
    end
  end

  def table_name_for_insert
    self.class.table_name
  end

  def col_names_for_insert
    column_name = []
    self.class.column_names.each do |transfer|
      column_name << transfer unless transfer == 'id'
    end
      column_name.join(", ")
  end

  def values_for_insert
    value = []
    self.class.column_names.each do |transfer|
      value << "'#{send(transfer)}'" unless send(transfer) == nil
    end
    value.join(", ")
  end

  def save
    sql = "INSERT INTO ? (?) VALUES (?)"

    DB[:conn].execute(sql, table_name_for_insert, col_names_for_insert, values_for_insert)

    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM (?)", table_name_for_insert)[0][0]
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM ? WHERE name=(?)"

    DB[:conn].execute(sql, table_name_for_insert, name)
  end

  def self.find_by(value)
    sql = "SELECT * FROM ? WHERE ?=(?)"

    DB[:conn].execute(sql, table_name_for_insert, value)
  end
end
