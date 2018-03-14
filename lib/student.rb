require_relative "../config/environment.rb"
require_relative 'interactive_record.rb'
require 'active_support/inflector'

class Student < InteractiveRecord

  self.column_names.each do |name|
    attr_accessor name.to_sym
  end

  def initialize(attributes={})
    attributes.each do |k, v|
      self.send("#{k}=", v)
    end
    self
  end

end
