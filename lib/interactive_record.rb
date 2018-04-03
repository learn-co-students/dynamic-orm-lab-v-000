require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'pry'

class InteractiveRecord

  def self.table_name
    self.to_s.downcase.pluralize
  end

  def table_name_for_insert
    self.class.table_name
  end

  def col_names_for_insert
    self.class.column_names.delete_if {|col| col == "id"}.join(", ")
  end

  def values_for_insert
    values = []
    self.class.column_names.each do |col|
      values << "'#{send(col)}'" unless send(col).nil?
    end
    values.join(", ")
  end

  def self.column_names
    sql = "PRAGMA table_info ('#{table_name}')"
    table_info = DB[:conn].execute(sql)
    col_names = []
    table_info.each do |col|
      col_names << col["name"]
    end
    col_names.compact
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
    key = attribute.keys.first
    clean_value = attribute.values.first.class == Fixnum ? attribute.values.first : "'#{attribute.values.first}'"
    sql = "SELECT * FROM #{self.table_name} WHERE #{key} = #{clean_value}"
    DB[:conn].execute(sql)
  end
end
