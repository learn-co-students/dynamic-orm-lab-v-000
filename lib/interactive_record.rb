require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord

  # class methods
  def self.table_name
    self.to_s.downcase.pluralize
  end

  def self.column_names
    DB[:conn].results_as_hash = true
    sql = "pragma table_info('#{table_name}')"
    table_info = DB[:conn].execute(sql)
    column_names = []
    table_info.each {|row| column_names.push(row["name"])}
    column_names.compact
  end

  def self.find_by_name(name)
    DB[:conn].execute("SELECT * FROM #{self.table_name} WHERE name = '#{name}'")
  end

  def self.find_by(attribute)
    column = attribute.keys[0].to_s
    value = attribute.values[0]
    DB[:conn].execute("SELECT * FROM #{self.table_name} WHERE #{column} = '#{value}'")
  end

  def table_name_for_insert
    self.class.table_name
  end

  # instance methods

  def initialize(data={})
    data.each {|key, value| self.send("#{key}=", value)}
  end

  def col_names_for_insert
    self.class.column_names.delete_if {|col| col == "id"}.join(", ")
  end

  def values_for_insert
    values = []
    self.class.column_names.each do |col_name|
      values.push("'#{self.send(col_name)}'") unless send(col_name).nil?
    end
    values.join(", ")
  end

  def save
    DB[:conn].execute("INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})")
    self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
    self
  end





end
