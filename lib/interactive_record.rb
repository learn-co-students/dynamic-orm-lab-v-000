require_relative "../config/environment.rb"
require 'active_support/inflector'

require 'pry'

class InteractiveRecord

  def self.table_name
    self.to_s.downcase.pluralize
  end

  def self.column_names
    #end result is "column_name_one", "column_name_two" etc
    DB[:conn].results_as_hash = true
    sql = "PRAGMA table_info ('#{table_name}')"

    table_info = DB[:conn].execute(sql)
    #returns array of hashes
    c_names = []

    table_info.each do |hash|
      c_names << hash["name"]
    end
    c_names.compact
    #binding.pry
  end

  def initialize(attributes={})
    attributes.each do |key, value|
      self.send("#{key}=", value)
    end
  end
  
  def table_name_for_insert
    self.class.table_name
  end

  def col_names_for_insert
    self.class.column_names.delete_if {|name| name == 'id'}.join(", ")
  end

  def values_for_insert
    #return example: "'Sam', '11'"
    values = []
    
    self.class.column_names.each {|name| values << "'#{self.send(name)}'" unless self.send(name).nil?}
    values.join(", ")
  end

  def save
    sql = "INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})"
    DB[:conn].execute(sql)

    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]

  end

  def self.find_by_name(name)
    #returns the matching row from a name argument 
    sql = "SELECT * FROM #{table_name} WHERE #{table_name}.name = name"
    DB[:conn].execute(sql)
  end

  def self.find_by(hash)
    hash.map do |key, value|
    DB[:conn].execute("SELECT * FROM #{table_name} WHERE #{key.to_s} = '#{value}'")
    #binding.pry
    end.first
  end
  
end