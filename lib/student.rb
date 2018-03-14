require 'pry'
require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'interactive_record.rb'

class Student < InteractiveRecord
  self.column_names.each do |col_name|
    attr_accessor col_name.to_sym
  end

  def self.find_by(hash)
    col_name=""
    val=""
    hash.map do |k,v|
      col_name = k.to_s
      val = v
    end
    sql = "SELECT * FROM #{self.table_name} WHERE #{col_name} = '#{val}'"
    DB[:conn].execute(sql)
  end
end
