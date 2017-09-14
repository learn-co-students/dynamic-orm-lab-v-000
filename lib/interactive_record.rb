require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord

  def self.table_name
  	self.to_s.downcase.pluralize
  end

  def self.column_names
  	#make all database queries return as a hash
  	DB[:conn].results_as_hash = true
  	#PRAGMA table_info makes SQL return information about the table. Thanks to the above line, the info is formatted as an array of hashes,
  	#each entry in the array a hash that describes information about that column
  	sql = "PRAGMA table_info('#{self.table_name}')"
  	table_info = DB[:conn].execute(sql)
  	#collects all the values of the name key into an array. Compact removes all nil values, just in case.
  	table_info.collect {|column| column["name"]}.compact
  end

  #turns col name into symbol and assigns it as an attr accessor!

  def initialize(options={})
  	options.each do |attr, value|
  		self.send(("#{attr}="), value)
  	end
  end

  def table_name_for_insert
  	self.class.table_name
  end

  def col_names_for_insert
  	self.class.column_names.delete_if{|col| col == "id"}.join(", ")
  end

end