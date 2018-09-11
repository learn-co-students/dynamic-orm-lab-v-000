require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord
  
  def self.table_name
    self.to_s.downcase.pluralize
  end
  
  def self.column_names
   DB[:conn].results_as_hash = true

    sql = "pragma table_info('#{table_name}')"

    table_info = DB[:conn].execute(sql)
    column_names = []
    table_info.each do |row|
      column_names << row["name"]
    end
    column_names.compact
  end
  
  def initialize(attributes={})
    attributes.each[1..-1] do |property, value|
      self.send("#{property}=", value)
    end
  end
  
  # def self.create table
  #   sql = <<-SQL
  #   CREATE TABLE IF NOT EXISTS #{self.table_name} (
  #   id INTEGER PRIMARY KEY,
  #   title TEXT,
  #   content TEXT)
  #   SQL
    
  #   db[:conn].execute(sql)
  # end
  
  # def save
  #   sql = <<-SQL
  #   INSERT INTO #{self.class.table} (title, content) values (?,?)
  #   SQL
  #   DB[:conn].execute(sql, self.title, self.content)
  # end
  
end