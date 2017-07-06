require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'interactive_record.rb'
require 'pry'

class Student < InteractiveRecord

  self.column_names.each do |col_name|
    attr_accessor col_name.to_sym
  end

  def self.find_by(hash)
  	k = ""
  	v = ""
  	hash.each do |key, value|
  		k = key.to_s
  		v = value
  	end
  	sql = "SELECT * FROM #{self.table_name} WHERE #{k} = '#{v}'"
   	DB[:conn].execute(sql)
  end

end
