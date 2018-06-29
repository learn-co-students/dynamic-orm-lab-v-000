require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord

  def self.table_name
      self.to_s.downcase.pluralize
  end

  def self.column_names
    sql = "PRAGMA table_info('#{self.table_name}')"
    results = DB[:conn].execute(sql)
    results.collect do |col_data|
      col_data['name']
    end
  end

  def initialize(attributes={})
    attributes.each do |attr, value|
      self.instance_variable_set("@#{attr}", value)
    end
  end

  def table_name_for_insert
    self.class.table_name
  end

  def col_names_for_insert
    self.class.column_names[1, self.class.column_names.length].join(", ")
  end

  def values_for_insert
    values = []
    self.class.column_names.each do |column|
      values << "'#{send(column)}'" unless send(column).nil?
    end
    values.join(", ")
  end

  def save
    sql = "INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})"
    DB[:conn].execute(sql)
    self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM #{self.table_name} WHERE name = ?"
    DB[:conn].execute(sql, name)
  end

  def self.find_by(attr_hash)
    key = attr_hash.keys.first == String ? attr_hash.keys.first : "'#{attr_hash.keys.first}'"
    value = attr_hash.values.first.class == Fixnum ? attr_hash.values.first : "'#{attr_hash.values.first}'"
    sql = "SELECT * FROM #{self.table_name} WHERE #{attr_hash.keys.first} = #{value}"
    DB[:conn].execute(sql)
  end

end
