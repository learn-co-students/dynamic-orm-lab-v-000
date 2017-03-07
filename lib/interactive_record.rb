require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'pry'

class InteractiveRecord

  def initialize(options={})
    options.each {|property,value| self.send("#{property}=",value)}
  end

  def self.table_name
    self.to_s.downcase.pluralize
  end

  def self.column_names
    sql = "pragma table_info (#{self.table_name})"
    table_info = DB[:conn].execute(sql)
    columns = []
    table_info.each {|column_info| columns << column_info[1]}
    columns
  end

  def table_name_for_insert
    self.class.table_name
  end

  def col_names_for_insert
    self.class.column_names.delete_if {|col_name| col_name == 'id'}.join(", ")
  end

  def values_for_insert
    self.col_names_for_insert.split(", ").collect {|col_name| "'#{self.send(col_name.to_sym)}'" }.join(", ")
  end

  def save
    DB[:conn].execute("INSERT INTO #{self.table_name_for_insert} (#{self.col_names_for_insert}) VALUES (#{self.values_for_insert})")
    self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{self.table_name_for_insert}")[0][0]
  end

  def self.find_by(option={})
    DB[:conn].execute("SELECT * FROM #{self.table_name} WHERE #{option.keys[0].to_s} = ?",option[option.keys[0]])
  end

end
