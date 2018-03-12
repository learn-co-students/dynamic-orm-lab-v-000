require_relative "../config/environment"
require 'active_support/inflector'
require 'interactive_record'

class Student < InteractiveRecord

  self.column_names.each do |col_name|
    attr_accessor col_name.to_sym
  end

end
