require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'pry'

class InteractiveRecord

  def self.table_name
    self.to_s.downcase.pluralize
  end

  def self.column_names
    DB[:conn].results_as_hash = true

    sql = <<-SQL 
      pragma table_info('#{table_name}')
      SQL

    table_information = DB[:conn].execute(sql)

    column_array = []

      table_information.each do |x|
      column_array << x["name"]
      end
    column_array.compact
  end

  def initialize(options = {})
    options.each do |key, value|
      self.send("#{key}=",value)
    end
  end

  def save
    sql = "INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})"
    DB[:conn].execute(sql)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  end

  def table_name_for_insert
    self.class.table_name
  end

  def col_names_for_insert
    column_names = []
    self.class.column_names.each do |x|
      column_names << x unless x == "id"
    end
    column_names.join(", ")
  end

  def values_for_insert
      values_array = []
      self.class.column_names.each do |x|
        values_array << "'#{send(x)}'" unless self.send(x).nil?
        end
    values_array.join(", ")
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM #{self.table_name} WHERE name = name"
    DB[:conn].execute(sql)
  end

  def self.find_by(attribute)
    key = []
    value = [] 
    attribute.each do |x, y| key << x
    value << y
    end 

    database = DB[:conn].execute("SELECT * FROM #{self.table_name} WHERE #{key.join} = '#{value.join}'")

  end

  
end
 