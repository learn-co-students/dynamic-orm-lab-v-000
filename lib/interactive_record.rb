require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord

  def initialize(attributes_hash={})
    attributes_hash.each do |attr_name, value|
      self.send("#{attr_name.to_s}=", value)
    end
  end

  def self.table_name
    self.to_s.downcase.pluralize
  end

  def self.column_names
    sql = <<-SQL
      PRAGMA table_info(#{self.table_name})
    SQL
    col_array = DB[:conn].execute(sql)

    column_names = []
    col_array.each do |column|
      column_names << column["name"]
    end

  column_names
  end

  def table_name_for_insert
    self.class.table_name
  end

  def col_names_for_insert
    self.class.column_names[1..-1].join(', ')
  end

  #remember to see how others implemented these methods better - too ugly!
  def values_for_insert
    self.class.column_names[1..-1].collect do |attrs|
      "'#{self.send(attrs)}'"
    end.join(', ')
  end

  def save
    sql = <<-SQL
      INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})
    SQL
    DB[:conn].execute(sql)

    #set the ID
    new_id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0]["last_insert_rowid()"]
    self.send("#{self.class.column_names.first}=", new_id)
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM #{self.table_name} WHERE name = (?) LIMIT 1
    SQL

    DB[:conn].execute(sql, name)
  end

  def self.find_by(finder_hash)
    attribute = finder_hash.keys[0].to_s
    sql = <<-SQL
      SELECT * FROM #{self.table_name} WHERE #{attribute} = (?) LIMIT 1
    SQL

    DB[:conn].execute(sql, finder_hash.values[0])
  end

end
