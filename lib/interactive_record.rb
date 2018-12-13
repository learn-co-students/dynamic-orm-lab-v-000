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
    table_info.collect {|table_column| table_column["name"]}
  end
end