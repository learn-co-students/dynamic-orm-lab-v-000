require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'interactive_record.rb'

class Student < InteractiveRecord

  self.column_names.each do |col_name|
    attr_accessor col_name.to_sym
  end

  def self.find_by(attributes)
    value = attributes.values[0]
    value.is_a?(String) ? value = "'#{value}'" : value = attributes.values[0]
    DB[:conn].execute("SELECT * FROM #{self.table_name} WHERE #{attributes.keys[0]} = #{value}")
  end

end
