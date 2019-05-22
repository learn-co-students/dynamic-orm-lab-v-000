require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord
  def self.table_name
    self.to_s.downcase.pluralize
  end

  def self.column_names
    table = DB[:conn].execute("PRAGMA table_info('#{self.table_name}')")
    table.collect{|column| column['name']}.compact
  end

  def table_name_for_insert
    self.class.table_name
  end

  def col_names_for_insert
    self.class.column_names.delete_if{|column| column == "id"}.join(", ")
  end

  def values_for_insert
    columns = self.class.column_names.delete_if{|column| column == "id"}
    columns.collect{|column|"'#{send(column)}'"}.join(", ")
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

  def self.find_by(hash)
    column = hash.keys.join(', ')
    value = hash.values.join(', ')
    sql = "SELECT * FROM #{self.table_name} WHERE #{column} = '#{value}'"
    DB[:conn].execute(sql)
  end
end
