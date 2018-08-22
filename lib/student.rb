require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'interactive_record.rb'
require 'pry'

class Student < InteractiveRecord

  self.column_names.each do |name|
    attr_accessor name.to_s
  end

  def initialize(options={})
     options.each do |property, value|
       self.send("#{property}=", value)
     end
   end


end
