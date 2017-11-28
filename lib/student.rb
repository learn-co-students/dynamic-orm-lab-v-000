require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'interactive_record.rb'

class Student < InteractiveRecord

  attr_accessor :name, :grade
  attr_reader :id

  def initialize(name: name, grade: grade, id: nil)
    @name = name
    @grade = grade
    @id = id
  end

end
