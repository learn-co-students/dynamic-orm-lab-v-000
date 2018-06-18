require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'pry'

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
    options.each do |property, value|
      self.send("#{property}=", value)
    end
  end

  def table_name_for_insert
    self.class.table_name
  end

  def col_names_for_insert
    self.class.column_names.delete_if {|col| col == "id"}.join(", ")
    #binding.pry
  end

  def values_for_insert
    values = []
    self.class.column_names.each do |col_name|
      values << "'#{send(col_name)}'" unless send(col_name).nil?
      #binding.pry
    end
    values.join(", ")
  end

  def save
    sql = "INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})"
    DB[:conn].execute(sql)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
    #binding.pry
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM #{self.table_name} WHERE name = '#{name}'"
    #binding.pry
    DB[:conn].execute(sql)
  end

  def self.find_by(options={})
    key1 = nil
    value1 = nil
    options.each do |key,value|
      key1 = key.to_s
      value1 = value
      #binding.pry
    end
    sql = "SELECT * FROM #{self.table_name} WHERE #{key1} = '#{value1}'"
    #binding.pry
    DB[:conn].execute(sql)
  end

end
