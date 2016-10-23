require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'pry'

class InteractiveRecord
  def self.table_name
    self.to_s.downcase.pluralize
  end

  def self.column_names
    DB[:conn].results_as_hash = true

    sql = "PRAGMA table_info('#{table_name}');"

    DB[:conn].execute(sql).each_with_object(names = []) do |row|
      names << row["name"]
    end.compact
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM #{table_name}
      WHERE name = ?
      LIMIT 1;
    SQL

    DB[:conn].execute(sql, name)
  end

  def self.find_by(attribute = {})
    column, value = attribute.first
    column = column.to_s

    sql = <<-SQL
      SELECT * FROM #{table_name}
      WHERE #{column} = '#{value}';
    SQL

    DB[:conn].execute(sql)
  end

  def initialize(attributes = {})
    attributes.each do |key, value|
      self.send("#{key}=",value)
    end
  end

  def table_name_for_insert
    self.class.table_name
  end

  def col_names_for_insert
    self.class.column_names.delete_if{|x| x == "id"}.join(", ")
  end

  def values_for_insert

    self.class.column_names.each_with_object(row = []) do |column|
      row << "'#{send(column)}'" unless send(column).nil?
    end.join(", ")
  end

  def save
    sql = <<-SQL
      INSERT INTO #{table_name_for_insert} (#{col_names_for_insert})
      VALUES (#{values_for_insert});
    SQL

    DB[:conn].execute(sql)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert};")[0][0]
  end
end

