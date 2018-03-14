require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord

  def self.table_name
    self.to_s.downcase.pluralize
  end

  def self.column_names
    sql = "PRAGMA table_info(#{self.table_name})"
    col_names = []
    DB[:conn].execute(sql).each do |col|
      col_names << col["name"]
    end
    col_names
  end

  def initialize(attributes = {})
    attributes.each do |attr, value|
      self.send("#{attr}=", value)
    end
  end

  def table_name_for_insert
    self.class.table_name
  end

  def col_names_for_insert
    self.class.column_names[1..-1].join(", ")
  end

  def values_for_insert
    values = []
    self.class.column_names[1..-1].each do |col_name|
      values << "'#{send(col_name)}'"
    end
    values.join(", ")
  end

  def save
    sql = <<-SQL
      INSERT INTO #{table_name_for_insert}
      (#{col_names_for_insert})
      VALUES (#{values_for_insert});
    SQL

    DB[:conn].execute(sql)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert};")[0][0]
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM #{self.table_name}
      WHERE name = ?;
    SQL

    DB[:conn].execute(sql, name)
  end

  def self.find_by(hash)
    key = hash.keys[0]
    value = hash.values[0]

    sql = <<-SQL
      SELECT * FROM #{self.table_name}
      WHERE #{key} = ?;
    SQL

    DB[:conn].execute(sql, value)
  end

end
