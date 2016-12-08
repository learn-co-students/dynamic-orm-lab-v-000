require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'pry'

class InteractiveRecord

  def self.table_name
  	self.to_s.downcase.pluralize
  end

  def self.column_names
  	DB[:conn].results_as_hash = true
    sql = "pragma table_info('#{table_name}')"
    column_names = []
    DB[:conn].execute(sql).each do |col_name|
      column_names << col_name['name']
    end
    column_names.compact
  end
   
  def initialize(options={})
  	options.each do |attr_name, value|
  	  self.send("#{attr_name}=", value)
  	end	
  end

  def save 
    sql = " INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})"
    DB[:conn].execute(sql)

    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  end

  def table_name_for_insert
  	self.class.table_name
  end

	def col_names_for_insert
	  self.class.column_names.delete_if{|column| column == 'id'}.join(', ')
	end

	def values_for_insert
		values = []
		self.class.column_names.each do|col_name|
		 values << "'#{send(col_name)}'" unless send(col_name).nil?
		end
		values.join(', ')
	end

	def self.find_by_name(name)
		sql = "SELECT * FROM #{self.table_name} WHERE name = ?"
		DB[:conn].execute(sql, name)
	end

	def self.find_by(attribute)
		
		data = []
		attribute.each do |key, value|
		  data << key
		  data << value 
		end

		sql = "SELECT * FROM #{self.table_name} WHERE #{data[0].to_s} = ?"
		DB[:conn].execute(sql, data[1])
	end

end