require_relative "../config/environment.rb"
require 'active_support/inflector'
require "pry"

class InteractiveRecord

  def initialize(attr_hash = {})
    attr_hash.each do |key, value|
      self.send(("#{key}="), value)
    end
  end

  def self.table_name
    self.to_s.downcase.pluralize
  end

  def self.column_names
     all_column_info = DB[:conn].execute("PRAGMA table_info(#{self.table_name})")
     all_column_info.map{| column | column["name"]}.compact
  end

  def self.column_names_no_id
    self.column_names.delete_if{|col| col == "id"}
  end

  def table_name_for_insert
    self.class.table_name
  end

  def col_names_for_insert
    self.class.column_names_no_id.join(", ")
  end

  def values_for_insert
    # `binding.pry
    column_values = self.class.column_names_no_id.map do |column|
      "'#{send(column)}'"
    end
    column_values.join(", ")
  end

  def save
    sql = <<-SQL
      INSERT INTO #{self.table_name_for_insert} (#{self.col_names_for_insert})
      VALUES (#{self.values_for_insert})
    SQL
    DB[:conn].execute(sql)
    self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM #{self.table_name}
      WHERE name = ?
    SQL
    DB[:conn].execute(sql, name)
  end

  def self.params_to_find(params)
    string = ""
    params.each do |key, value|
      string += "#{key} = '#{value}' AND "
    end
    string.chomp(" AND ")
    # binding.pry
  end

  def self.find_by(params)
    sql = <<-SQL
      SELECT * FROM #{self.table_name}
      WHERE #{self.params_to_find(params)}
    SQL
    DB[:conn].execute(sql)
  end
end
