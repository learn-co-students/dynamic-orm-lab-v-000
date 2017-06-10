require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord
  def self.table_name
    self.to_s.downcase.pluralize
  end

  def self.column_names
    DB[:conn].results_as_hash = true
    table_info = DB[:conn].execute("PRAGMA table_info('#{table_name}')")
    table_info.map do |row|
      row['name']
    end.compact
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
    self.class.column_names.delete_if do |col|
      col =="id"
    end.join(", ")
  end

  def values_for_insert
    self.class.column_names.map do |col|
      "'#{send(col)}'" unless send(col).nil?
    end.compact.join(", ")
  end

  def save
    sql = "INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})"
    DB[:conn].execute(sql)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM #{self.table_name} WHERE name = ?"
    DB[:conn].execute(sql, name)
  end

  def self.find_by(attr)
    DB[:conn].results_as_hash = true
    attr.map do |key, value|
      sql = "SELECT * FROM #{self.table_name} WHERE #{key} = '#{value}'"
      DB[:conn].execute(sql)
    end.flatten
  end

end
