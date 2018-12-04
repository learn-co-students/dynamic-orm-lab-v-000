require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'pry'

class InteractiveRecord
  def self.table_name
    self.to_s.downcase.pluralize
  end

  def self.column_names
    sql = "PRAGMA table_info('#{self.table_name}')"
    column_names = DB[:conn].execute(sql).collect {|column_hash|
      column_hash["name"]
    }.compact
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM #{self.table_name} WHERE name = ?"
    DB[:conn].execute(sql, name)
  end

  def self.find_by(attribute={})
    sql = "SELECT * FROM #{self.table_name} WHERE #{attribute.keys.first.to_s} = ?"
    DB[:conn].execute(sql, attribute.values.first)
  end

  def initialize(attributes={})
    attributes.each {|property, value|
      self.send("#{property}=", value)
    }
  end

  def table_name_for_insert
    self.class.table_name
  end

  def col_names_for_insert
    self.class.column_names.delete_if {|col_name| col_name == 'id'}.join(", ")
  end

  def values_for_insert
    values = self.class.column_names.collect {|col_name|
      "'#{self.send(col_name)}'" unless self.send(col_name).nil?
    }.compact.join(", ")
  end

  def save
    sql = "INSERT INTO #{self.table_name_for_insert} (#{self.col_names_for_insert}) VALUES (#{self.values_for_insert})"
    DB[:conn].execute(sql)
    self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{self.table_name_for_insert}")[0][0]
  end

end
