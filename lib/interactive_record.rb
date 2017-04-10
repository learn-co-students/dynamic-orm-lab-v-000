require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord

  def self.table_name
    self.to_s.downcase.pluralize
  end

  def self.column_names
    sql = "PRAGMA TABLE_INFO(#{self.table_name})"
    DB[:conn].execute(sql).map {|row| row["name"] }   
  end
  
  def initialize(options = {})
    options.each{|attribute, value| self.send("#{attribute}=", value)}
  end

  def table_name_for_insert
    self.class.table_name
  end

  def col_names_for_insert
    columns = self.class.column_names.delete_if{|column_name| column_name == 'id'}
    columns.join(', ')
    # binding.pry
  end

  def values_for_insert
    col_names_for_insert.split(', ').map{|col| "'#{self.send(col)}'"}.join(', ')
  end

  def save
    sql = "INSERT INTO #{self.class.table_name} (#{self.col_names_for_insert}) VALUES (#{self.values_for_insert})"
    DB[:conn].execute(sql)
    @id = DB[:conn].execute("SELECT last_insert_rowid();")[0][0]
  end

  def self.find_by(pair)
    attrib = pair.keys[0].to_s
    val = pair[pair.keys[0]]
    val = val.downcase unless val.is_a? Integer
    sql = "SELECT * FROM #{self.table_name} WHERE #{attrib} = ?;"
    binding.pry
    DB[:conn].execute(sql,val)    
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM #{self.table_name} WHERE name = ?;"
    DB[:conn].execute(sql, name)
  end
end