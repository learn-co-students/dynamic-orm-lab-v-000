require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord

  def self.table_name
    self.to_s.downcase.pluralize
  end

  def self.column_names
    sql = "PRAGMA table_info('#{table_name}')"
    info = DB[:conn].execute(sql)
    column_names = []
    info.each do |row|
      column_names << row["name"]
    end
    column_names.compact
  end

  def initialize(options = {})
    options.each do |key, value|
      self.send("#{key}=", value)
    end
  end

  def table_name_for_insert
    self.class.table_name
  end

  def col_names_for_insert
    self.class.column_names.delete_if { |name| name == "id"}.join(", ")
  end

  def values_for_insert
    values = []
    self.class.column_names.each do |name|
      values << "'#{send(name)}'" unless send(name).nil?
    end
    values.join(", ")
  end

  def save
    sql = "INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})"
    DB[:conn].execute(sql)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM #{self.table_name} WHERE name = '#{name}'"
    DB[:conn].execute(sql)
  end

  def self.find_by(options = {})
    statement = ""
    options.each do |attribute, value|
      value = "'#{value}'" if value.class == String
      statement = "#{attribute} = #{value}"
    end
    sql = "SELECT * FROM #{self.table_name} WHERE #{statement}"
    DB[:conn].execute(sql)
  end
  
end