require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord

	def self.table_name
		self.to_s.downcase.pluralize
	end

	def self.column_names
		DB[:conn].results_as_hash = true
		
		sql = "PRAGMA TABLE_INFO('#{table_name}');"
		column_info =  DB[:conn].execute(sql)
		column_names =[]
		column_info.each do |row|
			column_names << row['name']
		end
		column_names.compact
	end

	def initialize(input={})
		input.each do |key, value|
			self.send("#{key}=",value) #need to use string interpolation since there is a '='
		end
	end

	def save
		sql = "INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert});"

		DB[:conn].execute(sql)

		@id = DB[:conn].execute("SELECT last_insert_rowid()
			FROM #{table_name_for_insert};")[0][0]
	end

	def table_name_for_insert
		self.class.table_name
	end

	def col_names_for_insert
		self.class.column_names.delete_if do |col_name|
			col_name == "id"
		end. join(", ")
	end

	def values_for_insert
		col_values = []
		self.class.column_names.each do |col_name|
			col_values << "'#{self.send(col_name)}'" unless self.send(col_name).nil?
		end.join
		col_values.join(", ")
	end

	def self.find_by_name(name)
		#DB[:conn].results_as_hash = true
		sql = "SELECT * FROM #{table_name} WHERE name = ?;" #table name cannot use bound variable?
		DB[:conn].execute(sql, name)
	end
  
  def self.find_by(attribute={})
		#DB[:conn].results_as_hash = true
		sql = "SELECT * FROM #{table_name} WHERE  #{attribute.keys.first}= ?;" #table name cannot use bound variable?
		DB[:conn].execute(sql, attribute.values.first)
	end


end