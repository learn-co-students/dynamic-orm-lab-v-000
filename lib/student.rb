require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'interactive_record.rb'

class Student < InteractiveRecord

    self.column_names.each do |col_name|  #! This doesn't need to be in the initialize function. The column names are accessible because of the super class.
      attr_accessor col_name.to_sym   #each column in the table should have an attribute accessor for it, stored as a symbol
    end


end
