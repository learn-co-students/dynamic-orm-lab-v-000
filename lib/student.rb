require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'interactive_record.rb'

class Student < InteractiveRecord

    self.column_names.each do |col|
        attr_accessor col.to_sym
    end

    def initialize(id: nil, name: name, grade: grade)
        @name = name
        @grade = grade
    end
end
