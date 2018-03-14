require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'interactive_record.rb'

class Student < InteractiveRecord

  #iterate over the array of column names returned from InteractiveRecord's .column_names
  self.column_names.each do |col_name|
    attr_accessor col_name.to_sym
  end

end
