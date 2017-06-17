require_relative "../config/environment.rb"
require 'active_support/inflector'
require "pry"

class InteractiveRecord

  #ClassMethods

  def self.table_name
    self.to_s.downcase.pluralize
  end

  def self.column_names
    #return result as has, where column names are hash keys
    DB[:conn].results_as_hash = true

    sql = "pragma table_info('#{table_name}')"
    table_hash = DB[:conn].execute(sql)

    column_names = []

    table_hash.each {|column|
      column_names << column["name"]
    }

    column_names.compact
  end

  def initialize(options={})
    options.each {|key, val|
      self.send("#{key}=", val)
    }
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM #{self.table_name} WHERE name = '#{name}'"
    DB[:conn].execute(sql)
  end

  def self.find_by(attribute = {})
     sql = "SELECT * FROM #{self.table_name} WHERE #{attribute.keys[0]} = '#{attribute.values[0]}'"
     DB[:conn].execute(sql)
  end

  #InstanceMethods

  def save
    sql = <<-SQL
    INSERT INTO #{table_name_for_insert} (#{col_names_for_insert})
    VALUES (#{values_for_insert})
    SQL

    DB[:conn].execute(sql)

    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  end

  def table_name_for_insert
    self.class.table_name
  end

  def col_names_for_insert
    columns = self.class.column_names
    columns.delete("id")
    columns.join(', ')
  end

  def values_for_insert
    values_arr = []
    self.class.column_names.each { |column|
      values_arr << "'#{send(column)}'" unless send(column).nil?
    }
    values_arr.join(', ')
  end


end
