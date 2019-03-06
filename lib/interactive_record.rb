require 'pry'
require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord
  def self.table_name
    self.to_s.downcase.pluralize
  end

  def self.column_names
    DB[:conn].results_as_hash = true

    sql = "PRAGMA table_info('#{table_name}')"

    table_info = DB[:conn].execute(sql)

    column_names = []
    table_info.each do |column|
      column_names << column["name"]
    end
    column_names.compact
  end

  def initialize(options={})
    options.each do |key, value|
      self.send("#{key}=", value)
    end
  end

  def table_name_for_insert
    self.class.table_name
  end

  def col_names_for_insert
    col_names = self.class.column_names.delete_if {|col_name| col_name == "id"}.join(", ")
    col_names
  end

  def values_for_insert
  #  binding.pry
    values = []
    col_names = self.class.column_names.delete_if {|col_name| col_name == "id"}
    col_names.each do |column_name|
      values << "'#{send(column_name)}'" unless send(column_name).nil?
    end
    values.join(', ')
  end

  def save
    sql = "INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})"
    DB[:conn].execute(sql)
    #binding.pry
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  end

  def self.find_by_name(name)
    DB[:conn].execute("SELECT * FROM #{self.table_name} WHERE name = ?",name)
  end

  def self.find_by(options = {})
    col_name = options.keys.first.to_s
    value = options.values.first
  #   binding.pry
    DB[:conn].execute("SELECT * FROM #{self.table_name} WHERE #{col_name} = ?", value)
  end
end
