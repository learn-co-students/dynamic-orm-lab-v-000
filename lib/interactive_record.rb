require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'pry'

class InteractiveRecord

  def initialize(attributes={})
    attributes.each do |key, value|
      self.send(("#{key}="), value)
    end
  end


  def self.table_name
    table_name = "#{self.name.downcase}s"
  end

  def self.column_names
    sql = <<-SQL
    PRAGMA table_info(#{self.table_name})
    SQL
    table_info = DB[:conn].execute(sql)
    table_info.collect {|column| column["name"]}
  end

  def table_name_for_insert
    self.class.table_name
  end

  def col_names_for_insert
    #binding.pry
    self.class.column_names.reject{|col| col == "id"}.join(", ")
  end

  def values_for_insert
    col_list = self.class.column_names.reject{|col| col == "id"}
    col_list.collect {|col| "'#{send(col)}'"}.join(", ")
  end

  def save
    sql = <<-SQL
    INSERT INTO #{self.table_name_for_insert} (#{self.col_names_for_insert})
    VALUES (#{self.values_for_insert})
    SQL

    #binding.pry
    DB[:conn].execute(sql)
    #DB[:conn].execute(sql, self.table_name_for_insert, self.col_names_for_insert, self.values_for_insert)

    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{self.table_name_for_insert}")[0][0]
  end

  def self.find_by_name(name)
    sql = <<-SQL
    SELECT * FROM #{self.table_name}
    WHERE name = ?
    SQL

    DB[:conn].execute(sql, name)
  end

  def self.find_by(attribute)
    #binding.pry
    sql = <<-SQL
    SELECT * FROM #{self.table_name}
    WHERE "#{attribute.keys.join("")}" = ?
    SQL

    DB[:conn].execute(sql, attribute.values.join(""))
  end
end
