require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'interactive_record.rb'

class Student < InteractiveRecord
  
  self.column_names.each do |col_name|
    attr_accessor col_name.to_sym
  end
  
  def self.find_by(hash)
    value = hash.values.first
    edited_value = value.class == Fixnum ? value : "'#{value}'"
    sql = "SELECT * FROM #{self.table_name} WHERE #{hash.keys.first} = #{edited_value}"
    DB[:conn].execute(sql)
  end

end
