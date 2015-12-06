require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'pry'

class InteractiveRecord
  
  def initialize (hash = {})
    hash.each do |key, value|
      self.send("#{key}=", value)
    end
  end

  def self.table_name
    self.to_s.downcase.pluralize
  end

  def self.column_names
    columns = []
    info = DB[:conn].execute("PRAGMA table_info('#{table_name}')")
    info.each do |row|
      columns << row["name"]
    end
    columns
  end

  def self.find_by_name(name_to_find)
    query = "SELECT * FROM #{table_name} WHERE name = '#{name_to_find}'"
    find = DB[:conn].execute(query)
  end

  def table_name_for_insert
    self.class.table_name
  end

  def col_names_for_insert
    self.class.column_names.delete_if{|a| a == "id"}.join(", ")
  end

  def values_for_insert
    cols = self.class.column_names.delete_if{|a| a == "id"}
    vals = []
    cols.each do |column|
      vals << "'#{self.send("#{column}")}'" unless send(column).nil?
    end
    vals.join(", ")
  end

  def save
    query = "INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert});"
    DB[:conn].execute(query)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  end

  def self.find_by(hash)
    columns = self.column_names
    results = []
    columns.each do |col|
      query = "SELECT * FROM #{table_name} WHERE #{col} = '#{hash.values[0]}'"
      results << DB[:conn].execute(query) unless DB[:conn].execute(query).size < 1
    end
    results[0]
  end

end