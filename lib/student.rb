require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'interactive_record.rb'

class Student < InteractiveRecord
    attr_accessor :id, :name, :grade

  def initialize(options = {})
    options.each do |property, value|
      self.send("#{property}=", value)
    end
  end

end
