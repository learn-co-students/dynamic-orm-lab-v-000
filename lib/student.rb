require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'interactive_record.rb'

class Student < InteractiveRecord
  self.column_names.each do |col_name|              #convert string to symbol bc attr_accessor must be named with symbols
    attr_accessor col_name.to_sym
  end

end
