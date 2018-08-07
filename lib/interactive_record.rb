require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'pry'
class InteractiveRecord
  def self.table_name
    self.to_s.downcase.pluralize
  end

  def self.column_names
    info = DB[:conn].execute("PRAGMA table_info(#{self.table_name})")
    names = []
    info.each do |info_hash|
      names << info_hash["name"]
    end
    names
  end

  def initialize(attribute_hash = {})
    attribute_hash.each do |attribute, value|
      self.send("#{attribute}=", value)
    end
  end

  def table_name_for_insert
    self.class.to_s.downcase.pluralize
  end

  def col_names_for_insert
    self.class.column_names.delete_if do |name|
      name == "id"
    end.join(", ")
  end

  def values_for_insert
    columns = self.class.column_names.delete_if {|name| name == "id"}
    values = columns.map do |attribute|
        "'#{self.send(attribute)}'"
    end
    values.join(", ")
  end

  def save
    sql = <<-SQL
          INSERT INTO #{self.table_name_for_insert} (#{self.col_names_for_insert})
          VALUES (#{values_for_insert})
          SQL
    DB[:conn].execute(sql)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{self.table_name_for_insert}")[0][0]
  end

  def self.find_by_name(name)
    sql = <<-SQL
          SELECT * FROM #{self.table_name} WHERE name = ?
          SQL
    DB[:conn].execute(sql, name)
  end

  def self.find_by(attribute)
    sql = <<-SQL
          SELECT * FROM #{self.table_name} WHERE #{attribute.keys.first.to_s} = ?
          SQL
    DB[:conn].execute(sql, attribute.values.first)
  end
end
