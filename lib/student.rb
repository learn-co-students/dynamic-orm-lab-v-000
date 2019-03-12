require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'interactive_record.rb'

class Student < InteractiveRecord
 attr_accessor :id, :name, :grade
 
 def self.find_by_name(name)
    sql = "SELECT * FROM #{self.table_name} WHERE name = '#{name}'"
    DB[:conn].execute(sql)
  end

  # def self.find_by(value)
  #   sql = "SELECT * FROM #{self.table_name}"
  #   DB[:conn].execute(sql)
  # end
  
  def self.find_by(attr_hash)
    value = attr_hash.values.first
    formatted_value = value.class == Fixnum ? value : "'#{value}'"
    sql = "SELECT * FROM #{self.table_name} WHERE #{attr_hash.keys.first} = #{formatted_value}"
    DB[:conn].execute(sql)
  end
end
