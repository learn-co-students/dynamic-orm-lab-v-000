require_relative "../config/environment.rb"
# require 'active_support/inflector'

class InteractiveRecord

  def self.table_name
    "#{self.to_s.downcase}s"
  end

  def self.column_names
    columns = DB[:conn].execute("PRAGMA table_info(#{self.table_name})")
    columns.map { |column| column["name"] }.compact
  end

  def self.find_by_name(name)
    DB[:conn].execute("SELECT * FROM #{table_name} WHERE name = '#{name}'")
  end

  def self.find_by(attribute)
    DB[:conn].execute("SELECT * FROM #{table_name} WHERE #{attribute.keys.first} = '#{attribute.values.first}'")
  end

  def initialize(attributes = {})
    attributes.each { |key, value| self.send("#{key}=", value) }
  end

  def table_name_for_insert
    self.class.table_name
  end

  def column_names_without_id
    self.class.column_names.delete_if { |column| column == "id" }
  end

  def col_names_for_insert
    column_names_without_id.join(", ")
  end

  def values_for_insert
    column_names_without_id.map { |column| "'#{self.send(column)}'" }.join(", ")
  end

  def save
    sql = "INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})"
    DB[:conn].execute(sql)
    self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  end
  
end