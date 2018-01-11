require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'pry'

class InteractiveRecord
  def self.table_name
    self.to_s.downcase.pluralize
  end

  def self.column_names
    DB[:conn].results_as_hash = true

    sql = "PRAGMA table_info('#{table_name}')"

    table_info = DB[:conn].execute(sql)
    column_names = []
    table_info.each do |row|
      column_names << row["name"]
    end
    column_names.compact
  end

  def initialize(options={})
    options.each do |property, value|
      self.send("#{property}=", value)
    end
  end

  def table_name_for_insert
    self.class.table_name
  end

  def col_names_for_insert
    self.class.column_names.delete_if { |col| col == "id"}.join(", ")
  end

  def values_for_insert
    values_for_sql = []
    self.class.column_names.each do |col_name|
      values_for_sql << "'#{send(col_name)}'" unless send(col_name).nil?
    end
    values_for_sql.join(", ")
  end

  def save
    sql = <<-SQL
      INSERT INTO #{table_name_for_insert} (#{col_names_for_insert})
      VALUES (#{values_for_insert})
    SQL

    DB[:conn].execute(sql)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM #{table_name} WHERE name = ?"
    DB[:conn].execute(sql, name)
  end

  def self.find_by(any_attribute)
    key_array = []
    value_array = []
    any_attribute.each do |key, value|
      key_array << key
      value_array << value
    end
    sql = "SELECT * FROM #{table_name} WHERE #{key_array[0].to_s} = ?"
    DB[:conn].execute(sql, value_array[0])
  end
end
