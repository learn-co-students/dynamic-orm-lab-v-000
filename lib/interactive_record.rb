require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'pry'

class InteractiveRecord
  def initialize(options={})
    options.each do |key, value|
      self.send("#{key}=", value)
    end
  end

  def self.table_name

    self.to_s.downcase.pluralize

  end

  def self.column_names
    DB[:conn].results_as_hash = true

    table_info = DB[:conn].execute("PRAGMA table_info('#{table_name}')")

    table_info.collect do |info|
      info["name"]
    end.compact



  end

  def col_names_for_insert
    self.class.column_names.delete_if {|col| col == "id"}.join(", ")
  end

  def table_name_for_insert
    self.class.table_name
  end

  def values_for_insert
    values = []
    self.class.column_names.collect do |col|
      values << "'#{send(col)}'" unless send(col).nil?
    end
    values.join(", ")
  end

  def save
    sql = "INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})"

    DB[:conn].execute(sql)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  end

  def self.find_by(attr_hash)
    array = []
    attr_hash.each do |prop, val|
      array << prop.to_s
      array << val
    end

    sql = "SELECT * FROM #{self.table_name} WHERE #{array[0]} = '#{array[1]}'"
    DB[:conn].execute(sql)

  end

  def self.find_by_name(name)
    sql = "SELECT * FROM #{self.table_name} WHERE name = ?"
    DB[:conn].execute(sql, name)

  end

end