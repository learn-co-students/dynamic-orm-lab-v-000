require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'interactive_record.rb'

class Student < InteractiveRecord
  # binding.pry
  self.column_names.each {|col_name| attr_accessor col_name.to_sym}
end
