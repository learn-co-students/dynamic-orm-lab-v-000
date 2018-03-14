require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'interactive_record.rb'

class Student < InteractiveRecord
  #almost a lazy way to write attr_accessors
  self.column_names.each do |column|
      attr_accessor column.to_s
  end



end
