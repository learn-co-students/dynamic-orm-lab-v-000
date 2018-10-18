require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'pry'

class InteractiveRecord

  def self.table_name
    to_s.downcase.pluralize
  end

  def self.column_names
    table_info = DB[:conn].execute("PRAGMA table_info('#{table_name}')")
    table_info.map { |column_hash| column_hash["name"]  }.compact
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM #{table_name} WHERE name = ?"
    DB[:conn].execute(sql, name)
  end

  def self.find_by(attributes)
    attribute, value = attributes.keys[0], attributes.values[0]
    sql = "SELECT * FROM #{table_name} WHERE #{attribute} = ?"
    DB[:conn].execute(sql, value)
  end

  def initialize(attributes={})
    attributes.each { |attribute, value| send("#{attribute}=", value) }
  end

  def table_name_for_insert
    self.class.table_name
  end

  def col_names_for_insert
    self.class.column_names.delete_if { |name| name == "id" }.join(", ")
  end

  def values_for_insert
    values = []
    self.class.column_names.each { |name| values << "'#{send(name)}'" unless self.send(name).nil? }
    values.join(", ")
  end

  def save
    sql = "INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})"
    DB[:conn].execute(sql)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  end
end
