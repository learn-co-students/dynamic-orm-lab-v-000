require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'pry'

class InteractiveRecord

  #///CLASS METHODS///#
  def self.table_name
    self.to_s.downcase.pluralize
  end

  def self.column_names
    DB[:conn].results_as_hash = true
    sql = "pragma table_info('#{table_name}')"
    table_info = DB[:conn].execute(sql)
    column_names = Array.new
    table_info.each do |row|
      column_names << row["name"]
    end
    column_names.compact
  end

  #self.column_names.each do |col_name|
    #binding.pry
    #attr_accessor col_name.to_sym
  #end

  def initialize (args={})
    args.each do |property, value|
      #binding.pry
      self.send("#{property}=",value)
    end
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM #{table_name} WHERE name = '#{name}'"
    DB[:conn].execute(sql)
  end
  
  def self.find_by(args)
    sql = "SELECT * FROM #{table_name} WHERE #{args.keys[0]} = '#{args.values[0]}'"
    DB[:conn].execute(sql)
  end

  #///INSTANCE METHODS///#

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

  def col_names_for_insert
    cols = []
    self.class.column_names.each do |col_name|
      cols << col_name  unless col_name == 'id'
    end
    cols.join(", ")
  end

  def save
    sql = "INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})"
    DB[:conn].execute(sql)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  end
end