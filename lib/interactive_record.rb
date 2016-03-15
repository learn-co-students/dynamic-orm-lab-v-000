require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord

  def self.table_name
    self.to_s.downcase.pluralize
  end

  def self.column_names
    DB[:conn].results_as_hash = true
    sql = "PRAGMA table_info('#{table_name}')"
    DB[:conn].execute(sql).map {|row| row["name"]}.compact
  end

  # self.column_names.each do |column_name|
  #   attr_accessor column_name.to_sym
  # end

  def initialize(attributes={})
    attributes.each do |property, value|
      self.send("#{property}=", value)
    end
  end

  def table_name_for_insert
    self.class.table_name
  end

  def col_names_for_insert
    self.class.column_names.delete_if {|col| col == "id"}.join(", ")
  end

  def values_for_insert
    self.class.column_names.map do |column_name|
      "'#{send(column_name)}'" unless send(column_name).nil?
    end.compact.join(", ")
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

  def self.find_by(hash)
    result = nil
    hash.each do |key, val|
      sql = "SELECT * FROM #{self.table_name} WHERE #{key.to_s} = '#{val}'"
      result =  DB[:conn].execute(sql)
      break
    end
    result
  end

end