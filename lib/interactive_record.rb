require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord
  
  def initialize(attributes={})
    attributes.each do |attribute, value|
      self.send("#{attribute}=", value)
    end
  end
  
  def self.table_name
    self.to_s.downcase.pluralize
  end
  
  def self.column_names
    DB[:conn].results_as_hash = true
    
    sql = "PRAGMA table_info('#{table_name}')"
    
    table_info = DB[:conn].execute(sql)
    names = []
    table_info.each do |row|
      names << row["name"]
    end
    
    names
  end
  
  def table_name_for_insert
    self.class.table_name
  end
  
  def col_names_for_insert
    self.class.column_names.compact.delete_if{ |name| name == "id" }.join(", ")
  end
  
  def values_for_insert
    self.class.column_names.collect
  end
  
end