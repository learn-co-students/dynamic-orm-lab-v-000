require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'interactive_record.rb'
require 'pry'

class Student < InteractiveRecord

  attr_accessor :id, :name, :grade

  def initialize(options = {})
    options.each do |property, value|
      self.send("#{property}=", value)
    end
  end

end
