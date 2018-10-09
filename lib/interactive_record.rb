require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord
  def self.table_name
    self.to_s.downcase.pluralize
  end

  def self.column_names
    DB[:conn].results_as_hash = true

    columns = DB[:conn].execute("PRAGMA table_info(#{table_name})")
    names = []

    columns.each do |column|
    names << column["name"]
   end
    names.compact
  end

  def initialize(new_student={})
    new_student.each do |name, grade|
      self.send("#{name}=", grade)
    end
  end

  def table_name_for_insert
    self.class.table_name
  end

  def col_names_for_insert
     self.class.column_names.delete_if {|data| data == "id"}.join(", ")
  end

  def values_for_insert
    data = []
    self.class.column_names.each do |name|
    data << "'#{send(name)}'" unless send(name).nil?
    end
    data.join(", ")
  end

  def save
    sql = <<-SQL
      INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})
    SQL

    DB[:conn].execute(sql)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM #{table_name} WHERE name = ?
    SQL

    DB[:conn].execute(sql, name)
  end

  def self.find_by(name)
    row = name.keys[0].to_s
    attribute_value = name.values[0]

    sql = <<-SQL
      SELECT * FROM #{table_name} WHERE #{row} = ?
    SQL

    DB[:conn].execute(sql, attribute_value)
  end
end
