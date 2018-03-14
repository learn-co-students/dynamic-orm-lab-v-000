require_relative "../config/environment.rb"
# require 'active_support/inflector'
require 'interactive_record.rb'

class Student < InteractiveRecord
  #method for attr_accessors
  def self.attr_accessors
    self.column_names.each do |column_name|
      attr_accessor column_name
    end
  end

  attr_accessors

end
