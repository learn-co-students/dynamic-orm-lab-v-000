require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'interactive_record.rb'

class Student < InteractiveRecord
  
  self.column_names.each do |col_name|
    attr_accessor col_name.to_sym
  end
  # iterate over array of column names andwrite an attr_accessor for each
  # .to_sym turns string into a symbol

end
