require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'interactive_record.rb'

class Student < InteractiveRecord
  
  self.column_names.each do |col_name|
    attr_accessor col_name.to_sym
    # iterate over array of column names andwrite an attr_accessor for each
    # .to_sym turns string into a symbol
  end
  

  def initialize(options={})
    options.each do |prop, value|
      self.send("#{prop}=", value)
    end
    # iterate over hash and 
    # use #send to call a method whose name is the interpolated prop/key equals
    # and to pass the value in as an argument of prop/key=
    # this sets an instance's attributes based on key & value pairs
  end

  

end
