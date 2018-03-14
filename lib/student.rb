require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'interactive_record.rb'
#attr_accessor set in child class
class Student < InteractiveRecord
  self.column_names.each do |col_name|
    attr_accessor col_name.to_sym
  end
end
