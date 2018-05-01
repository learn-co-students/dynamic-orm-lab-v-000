require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'interactive_record.rb'
require 'pry'

class Student < InteractiveRecord

  ATTRIBUTES = {
    :id => 'INTEGER PRIMARY KEY',
    :name => 'TEXT',
    :grade => 'TEXT'
  }

  attr_accessor :id, :name, :grade

  def initialize(options={})
    options.each do |property, value|
      self.send("#{property}=", value)
    end
  end

  def self.table_name
      self.to_s.downcase.pluralize
  end

  def self.column_names
     ATTRIBUTES.keys.map do |a|
      a.to_s
    end
  end

  def table_name_for_insert
    self.class.table_name
  end

  def col_names_for_insert
    self.class.column_names.delete_if {|col| col == 'id'}.join(", ")
  end

  def values_for_insert
    values = []
      self.class.column_names.each do |col_name|
          values << "'#{send(col_name)}'" unless send(col_name).nil?
      end
      values.join(', ')
  end

  def save
    sql = "INSERT INTO #{self.table_name_for_insert} (#{self.col_names_for_insert}) VALUES (#{self.values_for_insert})"

    DB[:conn].execute(sql)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{self.table_name_for_insert}")[0][0]
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM #{self.table_name} WHERE name = '#{name}'"
    DB[:conn].execute(sql)
  end

  def self.find_by(attribute)
    sql = "SELECT * FROM #{self.table_name} WHERE #{attribute.keys[0].to_s} = '#{attribute.values[0].to_s}'"
    DB[:conn].execute(sql)
  end

end
