require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'interactive_record.rb'

class Student < InteractiveRecord


  # def self.attr_accessor
  #   binding.pry
  #
      self.column_names.each do |col_name|
        # binding.pry
        attr_accessor col_name.to_sym
    end
  # end
  #
  # def initialize(options={})
  #   # binding.pry
  #
  #   options.each do |property, value|
  #     # binding.pry
  #
  #     self.send("#{property}=", value)
  #     # binding.pry
  #   end
  # end

  # def self.find_by(attribute={})
  #   binding.pry
  #   sql = "SELECT * FROM #{self.table_name} WHERE name = #{name}"
  #   DB[:conn].execute(sql)
  # end


end

#
# require_relative "../config/environment.rb"
# require 'active_support/inflector'
# require 'interactive_record.rb'
#
# class Student < InteractiveRecord
#   self.column_names.each do |col_name|
#     attr_accessor col_name.to_sym
#   end
# end
