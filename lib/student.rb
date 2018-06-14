
require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'interactive_record.rb'

class Student < InteractiveRecord
  attr_accessor :name, :grade, :id

  def initialize(id: nil, name: name, grade: grade)
    @id = id
    @name = name
    @grade = grade
  end

end
