require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord

  def self.table_name
    table_name = self.to_s.downcase.pluralize
end

def self.column_names
  sql = "PRAGMA table_info('#{table_name}')"

  table_info = DB[:conn].execute(sql)
  column_names = []

  table_info.each do |column|
    column_names << column["name"]
  end
  column_names
end

def initialize(options={})
  options.each do |property, value|
    self.send("#{property}=", value)
  end
end

def table_name_for_insert
  self.class.table_name
end

def col_names_for_insert
  self.class.column_names.delete_if{|c|c == "id"}.join(", ")
end

def values_for_insert
  values = []
  self.class.column_names.each do |col_name|
    values << "'#{send(col_name)}'" unless send(col_name).nil?
  end
  values.join(", ")
end

def save
  sql = "INSERT INTO #{self.table_name_for_insert} (#{self.col_names_for_insert}) VALUES (#{self.values_for_insert})"
  DB[:conn].execute(sql)
  @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{self.table_name_for_insert}")[0][0]
end

def self.find_by_name(name)
  sql = "SELECT * FROM #{self.table_name} WHERE name = ?"

  DB[:conn].execute(sql, name)
end

def self.find_by(attr)
  key = attr.keys.first.to_s
  value = attr.values.first
  sql = "SELECT * FROM #{self.table_name} WHERE #{key} = '#{value}'"

  DB[:conn].execute(sql)
end

end 
