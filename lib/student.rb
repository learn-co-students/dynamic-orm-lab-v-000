require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'interactive_record.rb'

class Student < InteractiveRecord
  def initialize(attributes={})
    attributes.each{|k,v| self.send("#{k}=", v) }
  end

  self.column_names.each{ |column| attr_accessor column.to_sym }

end
