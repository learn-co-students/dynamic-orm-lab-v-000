require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'pry'
class InteractiveRecord

  def self.table_name
      self.to_s.downcase.pluralize
  end
  def self.column_names
      DB[:conn].results_as_hash = true
      table_info = DB[:conn].execute("PRAGMA table_info(#{self.table_name});")
      column_names = []

      table_info.each do |col|
          column_names << col["name"] unless col["name"].nil?
      end
      column_names
  end

  self.column_names.each do |col_name|
      attr_accessor col_name.to_sym
  end

  def initialize(options={})
      options.each do |property, value|
          self.send("#{property}=", value) unless property.nil?
      end
  end

  def table_name_for_insert
      self.class.table_name
  end

  def col_names_for_insert
      self.class.column_names.delete_if { |col_name| col_name == "id" }.join(", ")
  end

  def values_for_insert
      values = []
      self.class.column_names.each do |col_name|
          values << "'#{send(col_name)}'" unless send(col_name).nil?
      end
      values.join(", ")
  end

  def save
      sql = "INSERT INTO #{self.table_name_for_insert} (#{self.col_names_for_insert}) VALUES (#{self.values_for_insert})"
      DB[:conn].execute(sql)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{self.table_name_for_insert}")[0][0]
  end

  def self.find_by(attr)
      key = attr.keys.join.to_sym
      value = attr[key]
      sql = "SELECT * FROM #{self.table_name} WHERE #{key} = '#{value}'"
      DB[:conn].execute(sql)
  end

  def self.find_by_name(name)
      sql = "SELECT * FROM #{self.table_name} WHERE name = '#{name}'"
      DB[:conn].execute(sql)
  end

end
