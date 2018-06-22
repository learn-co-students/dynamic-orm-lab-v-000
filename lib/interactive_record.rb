require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord

  def self.table_name
      self.name.downcase.pluralize
  end

  def self.column_names
    sql = <<-SQL
      PRAGMA table_info(#{self.table_name})
    SQL

    names = DB[:conn].execute(sql)
    names = names.collect{ |name| name["name"]}.compact
  end

  def self.find_by(hash)
    sql = <<-SQL
      SELECT * FROM #{self.table_name} WHERE "#{hash.keys[0].to_s}" = "#{hash.values[0]}"
    SQL
    names = DB[:conn].execute(sql)
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM #{self.table_name} WHERE name = ?
    SQL

    DB[:conn].execute(sql, name)
  end

  def save
    sql = <<-SQL
      INSERT INTO #{table_name_for_insert} (#{col_names_for_insert})
      VALUES (#{values_for_insert})
    SQL

    DB[:conn].execute(sql)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  end

  def values_for_insert
    values = self.class.column_names.drop(1).collect do |col|
      "'#{send(col)}'"
    end
    values.join(', ')
  end

  def initialize(attributes = {})
    attributes.each do |key, value|
      self.send("#{key}=", value)
    end
  end

  def table_name_for_insert
    self.class.table_name
  end

  def col_names_for_insert
    self.class.column_names.drop(1).join(", ")
  end
end
