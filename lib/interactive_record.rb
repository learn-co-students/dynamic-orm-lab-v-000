require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'pry'
class InteractiveRecord
  def self.column_names
    sql = "PRAGMA table_info('#{self.table_name}')"
    table = DB[:conn].execute(sql)
    column_names = []
    table.each { |col| column_names << col["name"] }
    column_names
  end

  def self.table_name
    self.to_s.downcase.pluralize
  end

  def initialize(options={})
    options.each { |property,value| self.send("#{property}=",value) }
  end

  def table_name_for_insert
    self.class.table_name
  end

  def values_for_insert
    values = []
    self.class.column_names.each {|col| values << "'#{send(col)}'" if !send(col).nil? }
    values.join(", ")
  end

  def col_names_for_insert
    self.class.column_names.delete_if {|col| col=="id"}.join(", ")
  end

  def save
    DB[:conn].execute("INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert});")
    @id = DB[:conn].execute("SELECT id FROM #{table_name_for_insert} ORDER BY id DESC LIMIT 1")[0]["id"]
  end

  def self.find_by_name(name)
    DB[:conn].execute("SELECT * FROM #{table_name} WHERE name = ?;", name)
  end

  def self.find_by(options)
    DB[:conn].execute("SELECT * FROM #{table_name} WHERE #{options.keys[0].to_s} = \"#{options.values[0].to_s}\";")
  end
end
