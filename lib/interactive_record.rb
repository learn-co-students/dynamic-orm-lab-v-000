require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'pry'


class InteractiveRecord

def self.table_name
  self.to_s.downcase.pluralize
end

def self.column_names
  DB[:conn].results_as_hash = true
  sql = "PRAGMA table_info ('#{table_name}')" #returns an array of hashes( one for each column)
  column_names = []
  table_info = DB[:conn].execute(sql)
  table_info.each do |column|
    column_names << column["name"]
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
  values = []
  self.class.column_names.each do |col_name|
    values << "'#{send(col_name)}'" unless send(col_name).nil?
  end
  values.join(", ")
end

def save
  sql = <<-SQL
    INSERT INTO #{table_name_for_insert}
    (#{col_names_for_insert})
    VALUES (#{values_for_insert})
  SQL
  DB[:conn].execute(sql)
  @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
end

def self.find_by_name(name)
  sql = <<-SQL
    SELECT *
    FROM #{self.table_name}
    WHERE name = ?
  SQL
  DB[:conn].execute(sql, name)
end

def self.find_by(any_attribute = {})
  selected_prop = any_attribute.map {|prop, v| prop.to_s}.join("")
  selected_value = any_attribute.map {|prop,v| v}.join("")
  sql = <<-SQL
  SELECT *
  from #{self.table_name}
  WHERE #{selected_prop} = ?
  SQL
  DB[:conn].execute(sql, selected_value)
end


end
