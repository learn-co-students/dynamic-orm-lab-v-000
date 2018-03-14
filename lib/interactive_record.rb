require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'pry'

class InteractiveRecord
  def self.table_name
    self.to_s.downcase.pluralize
  end
  
  def table_name_for_insert
    self.class.table_name
  end
    
  def self.column_names
    sql = "pragma table_info('#{table_name}')"
    DB[:conn].execute(sql).map {|a| a["name"]}
  end
  
  def col_names_for_insert
    self.class.column_names.select {|a| a != "id"}.join(", ")
  end
  
  def values_for_insert
    col_name_array = self.class.column_names.map{|i| send(i)}.select {|a| a != nil}
    col_name_array_strings = col_name_array.map {|i| "'" + i.to_s + "'"}
    col_name_array_strings.join(", ")
  end
  
  def save
    sql = "INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert});"
    DB[:conn].execute(sql)
    a = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert};")
    @id = a[0]["last_insert_rowid()"]
  end
  
  def self.find_by_name(name_to_find)
    sql = "SELECT * FROM #{self.table_name} WHERE name = '#{name_to_find}'"
    DB[:conn].execute(sql)
  end
  
  def self.find_by(params={})
    sql = "SELECT * FROM #{self.table_name} WHERE "
    par_to_find = []
    params.each do |param, value|
      if value.is_a? Integer
        par_to_find << "#{param} = #{value}"
      else
        par_to_find << "#{param} = '#{value}'"
      end
    end
    sql << par_to_find.join(" AND ")
    sql << " LIMIT 1"
    DB[:conn].execute(sql)
  end
  
  def initialize(options={})
    options.each do |property, value|
      self.send("#{property}=", value)
    end
  end
end
