require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'pry'

class InteractiveRecord
  def self.table_name
    self.to_s.downcase.pluralize
  end
  
  def self.column_names
    sql = "PRAGMA table_info(#{self.table_name})"
    
    table_info = DB[:conn].execute(sql)
    table_info.collect {|table_column| table_column["name"]}.compact
  end
  
  def initialize(attributes = {})
    attributes.each {|key, value| self.send("#{key}=", value)}
  end
  
  def table_name_for_insert 
    self.class.table_name
  end
  
  def col_names_for_insert
    delete_column_name("id").join(", ")
  end
  
  def delete_column_name(name)
    self.class.column_names.delete_if {|col_name| col_name == name}
  end
  
  def values_for_insert
    values = self.class.column_names.collect do |col_name| 
      "'#{self.send(col_name)}'" unless self.send(col_name).nil?
    end
    
    values.compact.join(", ")
  end
end
