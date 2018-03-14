require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'pry'

class InteractiveRecord

  
  def self.table_name
    self.to_s.downcase.pluralize
  end
  
  def self.column_names
    sql = <<-SQL
    PRAGMA table_info('#{table_name}')
      SQL

    column_names = []
    DB[:conn].execute(sql).each do |column|
      column_names << column["name"]
    end

    column_names.compact
  end

  def initialize(options = {})
    options.each do |instance_var, value|
      self.send("#{instance_var}=", value)
    end
  end

  def save

    self.id ? update : insert

  end

  def insert
    sql = "INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})"

    DB[:conn].execute(sql)

    self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  end

  def table_name_for_insert
    self.class.table_name
  end

  def col_names_for_insert
    self.class.column_names.delete_if {|i| i == "id"}.join(", ")
  end

  def values_for_insert
    values = []

    self.class.column_names.each do |name|
      values << "'#{send(name)}'" unless send(name).nil?
    end

    values.join(", ")
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM #{self.table_name} WHERE name = ? LIMIT 1"

    row = DB[:conn].execute(sql, name)
  end

  def self.find_by(attr)
    sql = "SELECT * FROM #{self.table_name} WHERE #{attr.keys.first} = ? LIMIT 1"

    row = DB[:conn].execute(sql, attr.values.first)
  end

end