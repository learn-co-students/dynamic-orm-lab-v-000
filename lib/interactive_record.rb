require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'pry'

class InteractiveRecord

  def initialize(attributes = {})
    attributes.each do |attribute, value|
      self.send(("#{attribute}="), value)
    end
  end

  def self.table_name
    self.to_s.downcase.pluralize
  end

  def self.column_names
    DB[:conn].results_as_hash = true
    sql = "PRAGMA table_info(#{table_name});"

    table_columns = DB[:conn].execute(sql)
    column_names = []
    table_columns.each do |column|
      column_names << column["name"]
    end
    column_names.compact
  end

  def table_name_for_insert
    self.class.table_name
  end

  def col_names_for_insert
    columns = self.class.column_names.delete_if {|column| column == "id"}
    columns.join(", ")
  end

  def values_for_insert
    values = []
    self.class.column_names.each do |column|
      values << "'#{self.send(column)}'" unless send(column).nil?
    end
    values.join(", ")
  end

  def save
    sql = <<-SQL
    INSERT INTO #{table_name_for_insert} (#{col_names_for_insert})
    VALUES (#{values_for_insert});
    SQL
    DB[:conn].execute(sql)
    self.id = DB[:conn].last_insert_row_id
  end

  def self.find_by_name(name)
    sql = <<-SQL
    SELECT *
    FROM #{table_name}
    WHERE name = ?;
    SQL
    DB[:conn].execute(sql, name)
  end

  def self.find_by(attribute)
    key = attribute.keys.first
    value = attribute.values.first
    value_for_insert = value.class == Fixnum ? value : value = "'#{attribute.values.first}'"
    sql = <<-SQL
    SELECT *
    FROM #{self.table_name}
    WHERE #{key} = #{value_for_insert};
    SQL
    DB[:conn].execute(sql)
  end
end
