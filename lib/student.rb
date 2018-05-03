require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'interactive_record.rb'

class Student < InteractiveRecord

  self.column_names.each do |attr_name|
    attr_accessor attr_name.to_sym
  end

end
