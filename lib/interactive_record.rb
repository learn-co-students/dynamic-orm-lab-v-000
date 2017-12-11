require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord
  
  def initialize(attributes)
    attributes.each do |attribute, value|
      attr_accessor attribute.to_sym
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
  
end