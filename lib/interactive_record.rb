require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'pry'

class InteractiveRecord

  def self.table_name
    self.to_s.downcase.pluralize
  end

  def self.column_names
    table_name = self.table_name
    sql =<<-SQL
      PRAGMA table_info(#{table_name})
    SQL
    column_info = DB[:conn].execute(sql)
    column_names = []
    column_info.each do |column|
      column_names << column["name"]
    end
    column_names
  end

  def table_name_for_insert
    values_for_insert
    sql =<<-SQL
      INSERT INTO #{self.class.table_name} (#{self.col_names_for_insert}) VALUES (#{self.values_for_insert})
    SQL
    DB[:conn].execute(sql)
    self.class.table_name
  end

  def values_for_insert
    values = []
    self.class.column_names.each do |col_name|
      values << "'#{send(col_name)}'" unless send(col_name).nil?
    end
    return values.join(", ")
  end

  def col_names_for_insert
    column_names = []
    self.class.column_names.each do |col_name|
      column_names << col_name unless col_name == "id"
    end
    column_names.join(", ")
  end

  def save
    sql = <<-SQL
      INSERT INTO #{self.class.table_name} (#{self.col_names_for_insert}) VALUES (#{self.values_for_insert})
    SQL
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM #{self.table_name} WHERE name = name
    SQL
    DB[:conn].execute(sql)
  end

  def self.find_by(attribute)
    key = attribute.keys[0]
    value = attribute.values[0]
    sql = <<-SQL
      SELECT * FROM #{table_name} WHERE #{key} = "#{value}"
    SQL
    DB[:conn].execute(sql)
  end
end
