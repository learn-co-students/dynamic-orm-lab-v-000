require_relative "../config/environment.rb"
require 'active_support/inflector'
require_relative './interactive_record.rb'

class Student < InteractiveRecord

  self.column_names.each do |column_name|
    # puts "\n*** column_names *** #{column_name}\n"
    attr_accessor column_name.to_sym
  end

end
