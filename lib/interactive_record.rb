require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'pry'
class InteractiveRecord

  def self.table_name
    self.to_s.downcase.pluralize
  end

  def self.column_names
    sql = "PRAGMA table_info(#{self.table_name})"
    #binding.pry
    table_info = DB[:conn].execute(sql)

    column_names = []
    table_info.each do |column|
      column_names << column["name"]
    end
    column_names.compact
  end

  def initialize(attributes={})
    attributes.each do |key, value|
      self.send("#{key}=", value)
    end
  end

  def table_name_for_insert
    self.class.table_name.to_s
  end

  def col_names_for_insert
    col_names = self.class.column_names.delete_if{|col| col == "id"}.join(", ")
    #binding.pry
    col_names
  end

  def values_for_insert
    values = []

    self.class.column_names.each do |col_name|
      #binding.pry
      values << "'#{send(col_name)}'" unless send(col_name).nil?
    end
    values.join(", ")
  end

  def save
    sql = "INSERT INTO #{self.table_name_for_insert} (#{self.col_names_for_insert}) VALUES (#{self.values_for_insert})"

    DB[:conn].execute(sql)

    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{self.table_name_for_insert}")[0][0]
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM #{self.table_name} WHERE name = ?"
    DB[:conn].execute(sql, name)
  end

  def self.find_by(hash)
    sql = "SELECT * FROM #{self.table_name} WHERE #{hash.keys[0]} = ?"
    #binding.pry
    DB[:conn].execute(sql, hash[hash.keys[0]])
  end

  #{hash.keys[0].to_s}

end
