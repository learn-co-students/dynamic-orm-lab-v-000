require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'pry'

class InteractiveRecord


  def self.table_name
    self.to_s.downcase.pluralize
  end

  def self.column_names
    sql = "pragma table_info('#{table_name}')"
    DB[:conn].execute(sql).collect{ |row| row["name"] }
    #returns an array of all the columns name
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM #{table_name} WHERE name = ?
    SQL
    DB[:conn].execute(sql,name)
  end

  def self.find_by(attribute={})
    DB[:conn].results_as_hash = true
    sql = <<-SQL
      SELECT * FROM #{table_name} WHERE name = ? OR grade = ?
    SQL
    DB[:conn].execute(sql,attribute.values.first, attribute.values.first)
  end

  def initialize(attributes={})
    attributes.each { |k,v| self.send("#{k}=",v) }
  end

  def table_name_for_insert
    self.class.table_name
  end

  def col_names_for_insert
    #same as class.column_names w/o id
    #returns stings
    self.class.column_names.reject{|i| i=="id"}.join(", ")
  end

  def values_for_insert
      result = col_names_for_insert.split(", ").collect do |col|
         "'#{send(col)}'"
      end
      result.join(", ")
  end

  def save
      sql = <<-SQL
        INSERT INTO #{self.class.table_name} (name, grade) VALUES(?,?)
      SQL
      DB[:conn].execute(sql,self.name,self.grade)
      @id = DB[:conn].last_insert_row_id
  end

end
