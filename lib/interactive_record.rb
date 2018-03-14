require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'pry'

class InteractiveRecord

  def self.table_name
    self.to_s.downcase.pluralize
  end

  def self.column_names
    sql = "PRAGMA table_info(#{self.table_name})"
    DB[:conn].execute(sql).collect {|attribute| attribute["name"]}

  end

  def initialize(options={})
    options.each do |attribute, value|
      self.send("#{attribute}=", value)
    end
  end

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
    self.class.column_names.delete_if {|col| col == "id"}.join(", ")
  end

  def values_for_insert
    values = []
    self.class.column_names.delete_if {|col| col == "id" }.each do |name|
      values << "'#{self.send(name)}'"
    end
    values.join(", ")
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM #{table_name} WHERE name = ?"
    DB[:conn].execute(sql, name)
  end

  def self.find_by(attribute)
    #{:name=>"Susan"}
    # SELECT * FROM #{table_name} WHERE name = 'Susan'
    values = [] #["'Susan'"]
    keys = [] #["name"]
    attribute.each do |key, value|
      keys << key.to_s
      values << "'#{value.to_s}'"
    end
    sql = "SELECT * FROM #{table_name} WHERE #{keys[0]} = #{values[0]}"
    DB[:conn].execute(sql)


  end



end
