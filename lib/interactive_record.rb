require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord

  def self.table_name
    self.to_s.downcase.pluralize
  end

  def self.column_names
    DB[:conn].results_as_hash = true
    sql = "pragma table_info(#{table_name})"
    table_info = DB[:conn].execute(sql)
    column_names = []
    table_info.each do |row|
      column_names << row["name"]
    end
    column_names.compact
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
    self.class.column_names.drop(1).join(", ")
  end

  def values_for_insert
    values = []
    self.class.column_names.each do |column_name|
    values << "'#{send(column_name)}'" if send(column_name) != nil
  end
  values.join(", ")
  end

  def save
    sql = "INSERT INTO #{self.class.table_name} (#{self.col_names_for_insert}) VALUES (#{self.values_for_insert})"
    DB[:conn].execute(sql)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  end

  def self.find_by_name(name)
    sql = "SELECT * from #{self.table_name} WHERE name = ?"
    DB[:conn].execute(sql,name)
  end

  def self.find_by(attribute_hash)
  value = attribute_hash.values.first
  new_value = value.class == Fixnum ? value : "'#{value}'"
  sql = "SELECT * FROM #{self.table_name} WHERE #{attribute_hash.keys.first} = #{new_value}"
  DB[:conn].execute(sql)
  end





end
