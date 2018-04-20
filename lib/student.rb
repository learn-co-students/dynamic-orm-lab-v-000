require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'interactive_record.rb'

class Student < InteractiveRecord

  attr_accessor :id, :name, :grade
  #this will have to be moved to interactive_record

end
