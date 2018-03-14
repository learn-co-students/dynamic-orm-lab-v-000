require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord

  def self.table_name 
    self.to_s.downcase.pluralize 
  end

  def col_names_for_insert 
    self.class.column_names.delete_if { |col| col == "id" }.join(", ")
  end

  def values_for_insert
    values = []
    self.class.column_names.each do |col_name|
      values << "'#{send(col_name)}'" unless send(col_name).nil?
    end
    values.join(", ")
  end

  def table_name_for_insert
    self.class.table_name
  end

  def save
   sql = "INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})"
 
  DB[:conn].execute(sql)
 
  @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  end

  def initialize(options={})
    options.each do |property, value|
      self.send("#{property}=", value)
    end
  end

  def self.column_names
    DB[:conn].results_as_hash = true
    sql = "pragma table_info('#{table_name}')"
    table_columns = DB[:conn].execute(sql)
    column_names = [] 

    table_columns.each do |hash_of_table_rows|
      column_names << hash_of_table_rows["name"]
    end
    column_names.compact  #[returns an array of all column names]
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM #{self.table_name} WHERE name = '#{name}'"
    DB[:conn].execute(sql)
  end

  def self.find_by(attribute)
    key = attribute.keys.join  
    value = attribute.values.join
      # expected: [{"id"=>1, "name"=>"Susan", "grade"=>10, 0=>1, 1=>"Susan", 2=>10}]
      # got: {:name=>"Susan"}
      # i want the value like it comes out in the pragma sql in column names 
    sql = "SELECT * FROM '#{self.table_name}' WHERE (#{key}) = ?"
    DB[:conn].execute(sql, value)
  end
  
end