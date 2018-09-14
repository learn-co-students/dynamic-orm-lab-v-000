require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord
  
  def self.table_name
    self.to_s.downcase.pluralize
  end
  
  def self.column_names
    hash = DB[:conn].execute("PRAGMA table_info('#{self.table_name}')")
    columns_array = []
    hash.each {|column| columns_array << column["name"]}
    columns_array.compact
  end
  
  
  def initialize(hash = {})
    hash.each {|key, value| self.send("#{key}=", value)}
  end
  
  def table_name_for_insert
    self.class.table_name
  end
  
  def col_names_for_insert
    self.class.column_names.delete_if {|col_name| col_name == "id"}.join(', ')
  end
  
  def values_for_insert
    values = []
    self.class.column_names.each do |col_name|
      values << "'#{send(col_name)}'" unless send(col_name).nil?
    end
    values.join(', ')
  end
  
  def save
    DB[:conn].execute("INSERT INTO #{table_name_for_insert} (#{col_names_for_insert})
      VALUES (#{values_for_insert})")
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  end
  
  def self.find_by_name(name)
    DB[:conn].execute("SELECT * FROM #{table_name} WHERE name = ?", name)  
  end
  
  def self.find_by(attribute)
    att_key = ""
    att_value = ""
    attribute.each do |key, value|
      att_key += key.to_s
      att_value += value.to_s 
    end
    DB[:conn].execute("SELECT * FROM #{table_name} WHERE #{att_key} = ?", att_value)
  end
  
end