require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'interactive_record.rb'

class Student < InteractiveRecord

  #gets the columns names using inherited method, iterates across them and creates an attribute accessor for each one (turning them into symbols with to_sym)
  self.column_names.each do |col_name|
    attr_accessor col_name.to_sym
  end
  
end
