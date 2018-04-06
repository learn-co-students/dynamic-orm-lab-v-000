require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'interactive_record.rb'

class Student < InteractiveRecord


  self.column_names.each do |column|
    attr_accessor column.to_sym

  end

  def initialize(hash = {})
    hash.each do |key, value|
      self.send("#{key}=", value)
    end
  end

end
