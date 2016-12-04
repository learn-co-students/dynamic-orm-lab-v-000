require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'interactive_record.rb'

class Student < InteractiveRecord


    # We can tell our Song class that it should have an attr_accessor named after each column name with the following code:

      # This is metaprogramming because we are writing code that writes code for us.
      # By setting the attr_accessors in this way, a reader and writer method for each column name
      # is dynamically created, without us ever having to explicitly name each of these methods.


  self.column_names.each do |col_name|
    attr_accessor col_name.to_sym
  end
end
