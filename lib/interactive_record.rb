require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'pry'
class InteractiveRecord
#abstract class - we'll never instantiating this particular class by itself
  def self.table_name
    self.to_s.downcase.pluralize
  end

  def self.column_names
    DB[:conn].results_as_hash = true
    sql = <<-SQL
    PRAGMA table_info(#{self.table_name})
    SQL

    DB[:conn].execute(sql).collect do |hash|
      hash["name"]
    end
  end

  def initialize(attributes={})
    attributes.each {|key, value|
    self.send("#{key}=", value)}
  end

  def table_name_for_insert
    self.class.table_name
  end

  def col_names_for_insert
    col_names = self.class.column_names.delete_if {|name| name == "id"}
    col_names.join(", ")
  end

  # Note:
  # self.send(key=, value)
  # Is the same as:
  # instance_of_user.key = value

  def values_for_insert
    values = []
    self.class.column_names.each do |col_name|
    values << "'#{send(col_name)}'" unless send(col_name).nil?
    end
  values.join(", ")
  end

  def save
    sql = <<-SQL
    INSERT INTO #{self.table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})
    SQL

    DB[:conn].execute(sql)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  end

  def self.find_by_name(name)
    sql = <<-SQL
    SELECT * FROM #{self.table_name} WHERE name = ?
    SQL

    DB[:conn].execute(sql, name)
  end

  def self.find_by(attribute={})
    attribute.each do |key, value|
      @answer = DB[:conn].execute("SELECT * FROM #{self.table_name} WHERE #{key.to_s} = '#{attribute[key]}'")
    end
    @answer
  end

end
