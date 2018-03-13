require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'interactive_record.rb'

class Student < InteractiveRecord

  #create attr_accessors for student class here
  #iterate over each column name, make it a symbol, next to attr_accessor
  self.column_names.each do |col_name|
    attr_accessor col_name.to_sym
  end

end
