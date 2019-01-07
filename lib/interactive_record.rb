require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord
  
  def self.table_name
    self.to_s.downcase.pluralize
  end
  
  def self.column_names
    sql = <<-SQL
      PRAGMA table_info(#{table_name})
    SQL
    
    cols = DB[:conn].execute(sql)
    cols.collect do |col|
      col["name"]
    end
  end
  
  def initialize(args={})
    args.each do |k, v|
      self.send("#{k}=", v)
    end
  end
  
  def table_name_for_insert
    self.class.table_name
  end
  
  def col_names_for_insert
    self.class.column_names[1..-1].join(", ")
  end
  
  def values_for_insert
    values = []
    self.class.column_names.each do |col|
      values << "'#{send(col)}'" unless send(col).nil?
    end
    values.join(", ")
  end
  
  def save
    sql = <<-SQL
      INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) 
      VALUES (#{values_for_insert}) 
    SQL
    
    DB[:conn].execute(sql)
    @id = DB[:conn].last_insert_row_id
  end
  
  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM #{table_name}
      WHERE name='#{name}'
    SQL
    
    DB[:conn].execute(sql)
  end
  
  def self.find_by(arg)
    field = arg.keys[0].to_s
    value = arg.values[0]
    sql = <<-SQL
      SELECT * FROM #{table_name}
      WHERE #{field}='#{value}'
    SQL
    
    DB[:conn].execute(sql)
  end
  
end