require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord
  def initialize(hash={})
  	hash.each do |key, value|
  		self.send(("#{key}="), value)
  	end
  end

  def self.column_names
  	DB[:conn].results_as_hash = true

  	sql = "pragma table_info('#{table_name}')"
  	names = []
  	table_stuff = DB[:conn].execute(sql)
  	table_stuff.each do |table_row|
  		names << table_row["name"]
  	end
  	names.compact
  end

  def self.table_name
  	self.to_s.downcase.pluralize
  end

  def table_name_for_insert
  	self.class.table_name
  end

  def col_names_for_insert
  	self.class.column_names.delete_if{|col| col == "id"}.join(", ")
  end

  def values_for_insert
	columns = self.class.column_names.delete_if{|col| col == "id"}
	values = []
	columns.each do |col|
		values << ("'#{self.send(col)}'")
	end
	values.join(", ")
  end

  def save
  	sql = "INSERT INTO #{self.table_name_for_insert}(#{self.col_names_for_insert}) 
  			VALUES (#{values_for_insert})"
  	DB[:conn].execute(sql)

  	@id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
  end

  def self.find_by_name(name)
  	sql = "SELECT * FROM #{self.table_name} WHERE name = '#{name}'"
  	DB[:conn].execute(sql)
  end

  def self.find_by(attribute)
  	sql = "SELECT * FROM #{self.table_name} WHERE #{attribute.keys[0]} = '#{attribute.values[0]}'"
  	DB[:conn].execute(sql)
  end
end