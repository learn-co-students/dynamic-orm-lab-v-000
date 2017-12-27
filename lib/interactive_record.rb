require_relative "../config/environment.rb"
require 'active_support/inflector'

require 'pry'

class InteractiveRecord
  
    def self.table_name
        Student.inspect.downcase + "s"
        # binding.pry
    end

    def column_name
    end
end