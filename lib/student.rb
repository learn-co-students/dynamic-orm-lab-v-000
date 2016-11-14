require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'interactive_record.rb'

class Student < InteractiveRecord
  self.column_names.each do |column|
    attr_accessor column.to_sym
 end

  def initialize(options={})
  options.each do |property,value|
    self.send("#{property}=",value)
  end
end
end
