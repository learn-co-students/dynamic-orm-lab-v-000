require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'pry'

class InteractiveRecord

  def self.table_name
    self.to_s.downcase.pluralize
  end

  def self.drop_table
    sql = "DROP TABLE IF EXISTS #{self.table_name}"
    DB[:conn].execute(sql)
  end

  def self.column_names
    sql = "PRAGMA table_info(#{self.table_name})"
    column_names = []
    DB[:conn].execute(sql).each do |col|
      column_names << col["name"]
    end
    column_names
  end

  def initialize (options = {})
    options.each do |key, value|
      self.send("#{key}=", value)
    end
  end

  def table_name_for_insert
    self.class.table_name
  end

  def col_names_for_insert
    self.class.column_names.delete_if{|col| col == "id"}.join(", ")
  end

  def values_for_insert
    values = []
    self.class.column_names.each do |col|
      values << "'#{self.send(col)}'" unless send(col) == nil
    end
    values.join(", ")
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
    sql = <<-SQL
      SELECT * FROM #{table_name} WHERE name = ?
      LIMIT 1
    SQL
    DB[:conn].execute(sql, name).flatten
    # self.new_from_db(row)
  end

  def self.find_by(attribute_hash)
    attribute_hash.collect do |key, value|
      sql =  "SELECT * FROM #{table_name} WHERE #{key} = '#{value}'"
      #binding.pry
      DB[:conn].execute(sql)
    end.first
  end


end
