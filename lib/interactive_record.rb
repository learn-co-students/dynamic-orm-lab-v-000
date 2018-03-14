require_relative "../config/environment.rb"
require 'active_support/inflector'


class InteractiveRecord
  
  def self.table_name
  	self.to_s.downcase.pluralize
  end
  
  def self.column_names
  	DB[:conn].results_as_hash = true
  	
  	sql = "PRAGMA table_info('#{table_name}')"
  	column_names = []
  	table_info = DB[:conn].execute(sql)
  	table_info.each do |col|
  		column_names << col["name"]
  	end
  
  	column_names.compact
  end
  
  def initialize(options={})
  	options.each do |attribute, value|
  		self.send("#{attribute}=", value)
  		end
  end
  
  def table_name_for_insert
  	self.class.table_name
  end
  
  def col_names_for_insert
  	self.class.column_names.delete_if { |x| x == "id" }.join(", ")
  end
  
  def values_for_insert
  	values = []
  	
  	self.class.column_names.each do |x|
  		values << "'#{send(x)}'" unless send(x).nil?
  		end
  		
  	values.join(", ")
  end
  	
  def save
  	sql = <<-SQL
  		INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES
  		(#{values_for_insert})
  	SQL
  	
  	DB[:conn].execute(sql)
  	@id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  end
  
  def self.find_by(options={})
  	
  	sql=<<-SQL
  		SELECT * FROM #{table_name}
  		SQL
  	all = DB[:conn].execute(sql)
  	all.map { |x| options.all? { |y,z| x[y] == z} }
  	all
  end
  
  def self.find_by_name(name)
  	sql=<<-SQL
  		SELECT * FROM #{table_name} WHERE name = ?
  	SQL
  	
  	all = DB[:conn].execute(sql, name)
  	all
  end
  
  
end