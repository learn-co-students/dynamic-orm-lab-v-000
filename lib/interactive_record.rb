require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord
  def self.table_name
    self.to_s.downcase.pluralize
  end

  def initialize(attributes={})
    attributes.each do |property, value|
      self.send("#{property}=", value)
    end
  end

  def table_name_for_insert
    self.class.table_name
  end

  def col_names_for_insert
    self.class.column_names.delete_if {|name| name == "id"}.join(", ")
  end

  def values_for_insert
    values = []
    self.class.column_names.each do |name|
      values << "'#{self.send(name)}'" unless self.send(name) == nil
    end
    values.join(", ")
  end

  def save
    sql = <<-SQL
      INSERT INTO #{self.table_name_for_insert} (#{self.col_names_for_insert}) VALUES (#{self.values_for_insert})
    SQL
    DB[:conn].execute(sql)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM "#{self.table_name}" WHERE name = ?
    SQL

    DB[:conn].execute(sql, name)
  end

  def self.column_names
    sql = <<-SQL
      PRAGMA table_info('#{self.table_name}')
    SQL
    table_info = DB[:conn].execute(sql)
    names = []
    table_info.each do |column|
      names << column["name"]
    end
    names.compact
  end

  def self.find_by(obj)
    column = obj.keys[0].to_s.downcase
    value = obj[obj.keys[0]]
    sql = <<-SQL
      SELECT * FROM #{self.table_name} WHERE #{column} = \"#{value}\"
    SQL
    DB[:conn].execute(sql)
  end
end
