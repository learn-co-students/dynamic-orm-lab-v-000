require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'pry'

class InteractiveRecord

  def self.table_name
  	self.to_s.downcase.pluralize
  end

  def self.column_names
  	DB[:conn].results_as_hash = true
  	sql = "PRAGMA table_info('#{table_name}')"

  	table_info = DB[:conn].execute(sql)
  	columns = []
  	table_info.each do |column|
  		columns << column["name"]
  	end
  	columns
	end

	def initialize(attributes = {})
		attributes.each do |property, value|
			self.send("#{property}=", value)
		end
	end

	def table_name_for_insert 
		self.class.table_name
	end

	def col_names_for_insert
		self.class.column_names.delete_if { |column| column == "id"}.join(", ")
	end

	def values_for_insert 
		values = []
		self.class.column_names.each do |column|
			values << "'#{send(column)}'" unless send(column).nil?
		end
		values.join(", ")
	end

	def save
		sql = "INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})"
		DB[:conn].execute(sql)
		@id = DB[:conn].execute("SELECT LAST_INSERT_ROWID()")[0][0]
	end

	def self.find_by_name(name)
	  sql = "SELECT * FROM #{self.table_name} WHERE name = '#{name}'"
	  DB[:conn].execute(sql)
	end

	def self.find_by(attribute)
		sql = "SELECT * FROM #{self.table_name} WHERE #{attribute.keys.join} = '#{attribute.values.join}'"
		DB[:conn].execute(sql)
	end

end