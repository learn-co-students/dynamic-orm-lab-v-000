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
    columns = []

    column_info =  DB[:conn].execute(sql)
    column_info.each do |column|
      columns << "#{column["name"]}"
    end
    columns.compact
  end

  def self.find_by_name(name)
    DB[:conn].execute("SELECT * FROM #{self.table_name} WHERE name = '#{name}'")
  end

  def self.find_by (attribute_hash)
    #formatted_value = value.class == Fixnum ? value : "'#{value}'"
    #deals with value being integer
    col_name = attribute_hash.keys.first
    value = attribute_hash[col_name]
    sql = "SELECT * FROM #{self.table_name} WHERE #{col_name} = '#{value}'"
    DB[:conn].execute(sql)
  end

  def initialize (attributes = {})
    attributes.each do |property, value|
      self.send("#{property}=", value)
    end
  end

  def save
    sql = <<-SQL
      INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})
    SQL
    DB[:conn].execute(sql)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  end

  def table_name_for_insert
    self.class.table_name
  end

  def col_names_for_insert
    columns = self.class.column_names
    columns.delete_if {|col| col == "id"}.join(", ")
  end

  def values_for_insert
    values = []
    self.class.column_names.each do |col_name|
      values << "'#{self.send(col_name)}'" unless self.send(col_name).nil?
    end
    values.join(", ")
  end



end
