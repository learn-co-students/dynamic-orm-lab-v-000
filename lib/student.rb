require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'interactive_record.rb'
require 'pry'


class Student < InteractiveRecord

  self.column_names.each do |col_name|
   attr_accessor col_name.to_sym
  end

def self.find_by(arg)
  sql = "SELECT * FROM #{self.table_name} WHERE #{arg.keys[0]} = ?"

  DB[:conn].execute(sql, arg.values[0])
end

end
