require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord

	def initialize(info = {})
    info.each {|key, value| self.send("#{key}=", value)}
  end

  def save 
    sql = "INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})"
    DB[:conn].execute(sql)

    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  end

  def table_name_for_insert
    self.class.table_name
  end

  def col_names_for_insert
    self.class.column_names.reject {|col| col == "id"}.join(", ")
  end

  def values_for_insert
    self.class.column_names.reject {|col| col == "id"}.map {|col| "'#{self.send("#{col}")}'"}.join(", ")
  end

  def self.table_name
    self.to_s.downcase.pluralize
  end

  def self.column_names
    DB[:conn].execute("PRAGMA TABLE_INFO(#{self.table_name})").map {|col| col["name"]}
  end

  def self.find_by_name(name)
    sql = " SELECT * FROM #{self.table_name} WHERE name = ?"
    DB[:conn].execute(sql, name)
  end

  def self.find_by(info)
    contents = info.values.first
    format_content = contents.class == Fixnum ? contents : "'#{contents}'"
    sql = "SELECT * FROM #{self.table_name} WHERE #{info.keys.first} = #{format_content} "
    DB[:conn].execute(sql)
  end
  
end