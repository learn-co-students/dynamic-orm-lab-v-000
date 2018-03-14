require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord
  def self.table_name
    self.name.downcase.pluralize
  end

  def self.column_names
    sql = "PRAGMA table_info('#{table_name}')"

    table_info = DB[:conn].execute(sql)
    column_names = table_info.collect {|column| column["name"]}
  end

  def initialize(options={})
    options.each {|attribute, value| self.send("#{attribute}=", value)}
  end

  def table_name_for_insert
    self.class.table_name
  end

  def col_names_for_insert
    self.class.column_names[1..-1].join(", ")
  end

  def values_for_insert
    self.class.column_names[1..-1].collect {|attribute| "'#{send(attribute)}'"}.join(", ")
  end

  def save
    sql = "INSERT INTO #{table_name_for_insert}(#{col_names_for_insert}) VALUES (#{values_for_insert})"
    DB[:conn].execute(sql)

    key = "SELECT last_insert_rowid() FROM #{table_name_for_insert}"
    self.id = DB[:conn].execute(key)[0][0]
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM #{table_name} WHERE name = '#{name}'"
    DB[:conn].execute(sql)
  end

  def self.find_by(hash)
    sql = "SELECT * FROM #{table_name} WHERE #{hash.keys.first} = '#{hash.values[0]}'"
    DB[:conn].execute(sql)
  end
end
