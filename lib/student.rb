require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'interactive_record.rb'

class Student < InteractiveRecord
    self.column_names.each do |atr|
        attr_accessor atr.to_sym
    end
end
