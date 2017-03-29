require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord

  def initialize(attributes={})
		attributes.each do |key, value|
			self.send("#{key}=", value)
		end
	end

	def self.table_name()
		self.to_s.downcase.pluralize
	end

	def self.column_names()
		DB[:conn].execute("pragma table_info(students)").collect do |col_info|
			col_info["name"]
		end
	end

	def self.find_by(values)
		condition = values.collect {|key, value| "#{key} = '#{value}'"}.join(" AND ")
		DB[:conn].execute("SELECT * FROM #{table_name} WHERE #{condition}")
	end

	def self.find_by_name(name)
		find_by(name: name)
	end

	def table_name_for_insert()
		self.class.table_name
	end

	def col_names_for_insert()
		self.class.column_names.delete_if{|name|name=="id"}.join(', ')
	end

	def values_for_insert()
		column_values = []#Use each instead of collect so we can NOT add the id column
		self.class.column_names.each do |name|
			column_values << "'"+self.send("#{name}").to_s+"'" unless name=="id"
		end
		column_values.join(', ')
	end

	def save
		DB[:conn].execute("INSERT INTO students(#{col_names_for_insert}) VALUES (#{values_for_insert})")
		self.id = DB[:conn].execute("SELECT last_insert_rowid()")[0][0]
	end

end
