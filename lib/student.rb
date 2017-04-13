require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'interactive_record.rb'

class Student < InteractiveRecord

  self.column_names.each do |colmn_name|
    attr_accessor colmn_name.to_sym
  end

end
