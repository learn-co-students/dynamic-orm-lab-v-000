require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'interactive_record.rb'

class Student < InteractiveRecord
# creates a new student with attr_accessor s for each column
  self.column_names.each do |col_name|
    attr_accessor col_name.to_sym
  end
end
