require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'pry'

class InteractiveRecord

  def self.table_name
    self.to_s.downcase.pluralize
  end

  def self.column_names #returns array of the column names currently in the DB table
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
    attributes.each do |key, value|
      self.send("#{key}=", value)
    end
  end

  def table_name_for_insert #why are these all instance methods?
    self.class.table_name
  end

  def col_names_for_insert #used to input columns in #save (without id, automatically assigned)
    self.class.column_names.delete_if {|col| col == "id"}.join(", ")
  end

  def values_for_insert #assigns values to the columns in the DB (excluding id)
    values = []
     self.class.column_names.each do |col_name|
       values << "'#{send(col_name)}'" unless send(col_name).nil? # #send seems to grab the value for col_name
     end
   values.join(", ")
  end

  def save
   sql = "INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})"
   DB[:conn].execute(sql)
   @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM #{self.table_name} WHERE name = ?"
    DB[:conn].execute(sql, name)
  end

  # def self.find_by(attribute) # input will be: {name: "Susan"}, how to convert?
  #   column = attribute.keys.flatten[0].to_s
  #   data = attribute.values.flatten[0]
  #   # binding.pry
  #   sql = "SELECT * FROM #{self.table_name} WHERE '#{column}' = '#{data}'"
  #   DB[:conn].execute(sql)
  # end

  def self.find_by(attribute)
    # column = attribute.keys.flatten[0].to_s
    # data = attribute.values.flatten[0]
    # binding.pry
    sql = "SELECT * FROM #{self.table_name} WHERE '#{attribute.keys.flatten[0].to_s}'= '#{attribute.values.flatten[0]}'"
    DB[:conn].execute(sql)
  end


end
