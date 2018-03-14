require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord

  def self.table_name
    "#{self}".downcase.pluralize
  end

  def table_name_for_insert
    self.class.table_name
  end

  def self.column_names
    DB[:conn].results_as_hash = true

    sql = "PRAGMA table_info('#{table_name}')"

    table_info = DB[:conn].execute(sql)
    column_names = []
    table_info.each do |hash|
      column_names << hash["name"]
    end
    column_names.compact
  end

  def initialize(attributes = {})
    attributes.each { |attribute, value| self.send("#{attribute}=", value) }
  end

  def col_names_for_insert
    self.class.column_names.delete_if { |col_name| col_name == "id" }.join(", ")
  end

  def values_for_insert
    values = []
    self.class.column_names.each do |col_name|
      values << "'#{send(col_name)}'" if send(col_name) != nil
    end
    values.join(", ")
  end

  def save
    sql = "INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert});"
    DB[:conn].execute(sql)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM #{self.table_name} WHERE name = '#{name}'"
    DB[:conn].results_as_hash = true
    DB[:conn].execute(sql)
  end

  def self.find_by(hash)
    sql = "SELECT * FROM #{self.table_name} WHERE #{hash.keys[0].to_s} = '#{hash.values[0]}'"
    DB[:conn].results_as_hash = true
    DB[:conn].execute(sql)
  end

end
