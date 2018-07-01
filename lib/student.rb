require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'interactive_record.rb'

class Student < InteractiveRecord

  #need to set attr_accessors in a meta way
  self.column_names.each do |col_name|
    attr_accessor col_name.to_sym #symbol version of each col name
  end

end
