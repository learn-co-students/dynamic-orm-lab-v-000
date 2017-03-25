require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'pry'

class InteractiveRecord

  def self.table_name
    self.to_s.downcase.pluralize
  end

  def self.column_names
    DB[:conn].results_as_hash = TRUE
    table_info = DB[:conn].execute("PRAGMA table_info(#{table_name})")
    column_names = table_info.collect do |col_hash|
      col_hash["name"]
    end
    column_names.compact
  end

  def initialize(values = {})
    values.each do |attr_name, attr_value|
      self.send("#{attr_name}=", attr_value)
    end
  end

  def table_name_for_insert
    self.class.table_name
  end

  def values_for_insert
    instance_attrs = self.class.column_names.collect do |col_name|
      "'#{self.send(col_name)}'" unless send(col_name) == nil
    end
    instance_attrs.compact.join(", ")
  end

  def col_names_for_insert
    self.class.column_names.delete_if {|col| col == "id"}.join(", ")
  end

  def save
    DB[:conn].execute("INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})")

    self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  end

  def self.find_by_name(name)
    DB[:conn].execute("SELECT * FROM #{table_name} WHERE name = ?", name)
  end

  def self.find_by(attribute_hash)
    found = nil
    attribute_hash.each do |key, value|
      found = DB[:conn].execute("SELECT * FROM #{table_name} WHERE #{key.to_s} = ?", value)
    end
    found
  end

end
