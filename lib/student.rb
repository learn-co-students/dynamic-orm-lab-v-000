require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'interactive_record.rb'

class Student < InteractiveRecord

  self.column_names.each do |col_name|
    attr_accessor col_name.to_sym
  end


  def self.find_by(name: nil, grade: nil)
    sql = "SELECT * FROM #{self.table_name} WHERE name = ? OR grade = ?"
    DB[:conn].execute(sql, name, grade)
  end

end
