require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'interactive_record.rb'

class Student < InteractiveRecord
  self.column_names.each do |column_name|
    attr_accessor column_name.to_sym
    #attr_accessor is an instance trait, like animals become TYPES of animals when instantiated, so the animal class of traits won't pass to an instance of 1 type, so is the same with instances of classes not inheriting instance traits of their parents
  end
end
