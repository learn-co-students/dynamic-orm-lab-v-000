require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'pry'

class InteractiveRecord

  def self.table_name
    self.to_s.downcase.pluralize
  end


  def self.column_names

    sql = <<-SQL
      PRAGMA table_info("#{self.table_name}")
    SQL

    table_columns = []

    DB[:conn].execute(sql).each do |column|
      table_columns << column["name"]
    end
    table_columns
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
    self.class.column_names.delete_if {|column| column == "id"}.join(", ")
  end

  def values_for_insert
    values = []
    self.class.column_names.each do |column_name|
      values << "'#{self.send(column_name)}'" unless self.send(column_name).nil?
    end
    values.join(", ")
  end

  def save
    sql = <<-SQL
      INSERT INTO #{self.table_name_for_insert}(#{col_names_for_insert})
      VALUES (#{values_for_insert})
    SQL

    DB[:conn].execute(sql)
    self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{self.table_name_for_insert}")[0][0]
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM #{self.table_name}
      WHERE name = ?
    SQL

    DB[:conn].execute(sql, name)

  end

  def self.find_by(hash)
    sql = <<-SQL
      SELECT * FROM #{self.table_name}
      WHERE #{hash.keys[0].to_s} = ?
    SQL

    DB[:conn].execute(sql, hash[hash.keys[0]])

  end


end
