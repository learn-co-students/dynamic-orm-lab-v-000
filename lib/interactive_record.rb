require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord
  def self.table_name
    self.to_s.downcase.pluralize
  end

  def self.column_names
    sql = "Pragma table_info('#{table_name}');"
    table_info = DB[:conn].execute(sql)
    column_names = []
    table_info.each { |row| column_names << row["name"] }
    column_names.compact
  end

  def initialize(attrs={})
    attrs.each { |k,v| send("#{k}=", v) }
  end

  def table_name_for_insert
    self.class.table_name
  end

  def col_names_for_insert
    self.class.column_names.reject { |col_name| col_name == "id" }.join(", ")
  end

  def values_for_insert
    values = []
    self.class.column_names.each { |col_name| values << "'#{send(col_name)}'" unless send(col_name).nil? }
    values.join(", ")
  end

  def save
    sql = "INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})"
    DB[:conn].execute(sql)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM #{table_name} WHERE name = ?"
    DB[:conn].execute(sql, name)
  end

  def self.find_by(attr)
    sql = "SELECT * FROM #{table_name} WHERE #{attr.keys.first} = ?"
    DB[:conn].execute(sql, attr.values.first)
  end
end
