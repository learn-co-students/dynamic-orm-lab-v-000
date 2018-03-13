require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord
    
  def self.table_name
    self.to_s.downcase.pluralize
  end
  
  def self.column_names
    DB[:conn].results_as_hash = true
    sql = "PRAGMA table_info('#{table_name}')"
    table_info = DB[:conn].execute(sql)
    column_names = []
    table_info.each {|column| column_names << column["name"]}
    column_names.compact
  end
  
  def initialize(options={})
    options.each {|property, value| self.send("#{property}=", value)}
  end
  
  def table_name_for_insert
    self.class.table_name
  end
  
  def col_names_for_insert
    col_names = self.class.column_names.map {|x| x if x != "id"}
    col_names.compact!.join(", ")
  end
  
  def values_for_insert
    values = self.class.column_names.map {|x| "'#{send(x)}'" unless send(x).nil?}
    values.compact!.join(", ")
  end
  
  def save
    sql = "INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})"
    DB[:conn].execute(sql)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  end
  
  def self.all
    sql = "SELECT * FROM #{table_name}"
    DB[:conn].execute(sql)
  end
  
  def self.find_by_name(name)
    self.all.map {|x| x if x["name"] == name}
  end
  
  def self.find_by(attr)
    db_attr = self.column_names.map {|x| x.to_sym}
    if db_attr.include?(attr.keys[0]) 
      self.all.map {|x| x if x[attr.keys[0].to_s] == attr.values[0]}.compact
    end
  end

end