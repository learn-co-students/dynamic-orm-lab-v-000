require_relative "../config/environment.rb"
require 'active_support/inflector'
require "pry"
class InteractiveRecord
  def self.table_name
    self.to_s.downcase.pluralize
  end

  def self.column_names
    DB[:conn].results_as_hash = true

    sql = "PRAGMA TABLE_INFO('#{table_name}')"

    table_info = DB[:conn].execute(sql)

    table_info.map{|col| col["name"]}.compact
  end

  def initialize(options={})
    options.each do |k,v|
      self.send("#{k}=",v)
    end
  end

  def table_name_for_insert
    self.class.table_name
  end

  def col_names_for_insert
    self.class.column_names.map { |col| col unless col == 'id'}.compact.join(", ")
  end

  def values_for_insert
    self.class.column_names.map do |col|
      "'#{send(col)}'" unless send(col).nil?
    end.compact.join(", ")
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

  def self.find_by(options={})
    sql = ""
    options.map do |k,v|
      sql = "SELECT * FROM #{table_name} WHERE #{k.to_s} = '#{v}';"
    end
    DB[:conn].execute(sql)
  end
end
