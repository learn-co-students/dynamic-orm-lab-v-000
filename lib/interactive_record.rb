require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord
  
  def initialize(attributes={})
    attributes.each do |attribute, value|
      self.send("#{attribute}=", value)
    end
  end
  
  def self.table_name
    self.to_s.downcase.pluralize
  end
  
  def self.column_names
    DB[:conn].results_as_hash = true
    
    sql = "PRAGMA table_info('#{table_name}')"
    
    table_info = DB[:conn].execute(sql)
    names = []
    table_info.each do |row|
      names << row["name"]
    end
    
    names
  end
  
  def table_name_for_insert
    self.class.table_name
  end
  
  def col_names_for_insert
    self.class.column_names.compact.delete_if{ |name| name == "id" }.join(", ")
  end
  
  def values_for_insert
    self.class.column_names.collect do |column_name|
      "'#{send(column_name)}'" unless send(column_name) == nil
    end.delete_if{ |value| value == nil }.join(", ")
  end
  
  def save
    sql = <<-SQL
      INSERT INTO #{self.table_name_for_insert} (#{self.col_names_for_insert})
      VALUES (#{values_for_insert})
    SQL
    
    DB[:conn].execute(sql)
    
    self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{self.table_name_for_insert}")[0][0]
  end
  
  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM #{self.table_name}
      WHERE name = ?
    SQL
    
    DB[:conn].execute(sql, name)
  end
  
  def self.find_by(attribute={})
    sql = <<-SQL
      SELECT * FROM #{self.table_name}
      WHERE #{attribute.keys.first.to_s} = '#{attribute[attribute.keys.first]}'
    SQL
    
    DB[:conn].execute(sql)
  end
end