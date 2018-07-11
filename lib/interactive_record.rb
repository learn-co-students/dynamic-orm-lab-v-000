require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'pry'

class InteractiveRecord

  def self.table_name
    self.to_s.downcase.pluralize
  end

  # returns the column names for the table associated with this class
  def self.column_names
    table_info = DB[:conn].execute("PRAGMA table_info(#{table_name});")
    return table_info.collect {|column| column ["name"]}
  end

  def table_name_for_insert
    self.class.table_name
  end

  def col_names_for_insert
    self.class.column_names.select {|name| name != "id"}.join(", ")
  end

  def values_for_insert
    # could do this programmatically...
    "'#{self.name}', '#{self.grade}'"
  end

  def save
    sql = <<-SQL
          INSERT INTO #{table_name_for_insert}
          (#{col_names_for_insert})
          VALUES (#{values_for_insert});
          SQL

    DB[:conn].execute(sql)
    self.id = DB[:conn].execute("SELECT MAX(id) FROM students")[0]["MAX(id)"]
  end

  def self.find_by_name(name)
    sql = <<-SQL
          SELECT * FROM #{table_name}
          WHERE name = '#{name}'
          SQL
    DB[:conn].execute(sql)
  end

  def self.find_by(attribute)
    # the official solution does not put quotes around value if fixnum
    col_name_for_find = attribute.keys[0]
    value = attribute[col_name_for_find]
    value_for_find = value.class == Fixnum ? value : '#{value}'
    sql = <<-SQL
          SELECT * FROM #{table_name}
          WHERE #{key_for_insert} = #{value_for_insert}
          SQL
    DB[:conn].execute(sql)
  end

end
