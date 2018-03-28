require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'interactive_record.rb'

class Student < InteractiveRecord

  self.column_names.each do |col_name| #we need this to create the attributes for this class!
    attr_accessor col_name.to_sym
  end

end
