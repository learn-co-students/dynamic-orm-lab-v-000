require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'pry'
class InteractiveRecord

  def self.table_name
    self.to_s.downcase.pluralize
  end

  def self.column_names
    sql = "PRAGMA table_info('#{table_name}')"

    table_info = DB[:conn].execute(sql)
    column_names = []

    table_info.each do |column|
      column_names << column["name"]
    end

    column_names.compact
  end

  def self.find_by_name(name)
    DB[:conn].execute("SELECT * FROM #{table_name} WHERE name = ?", name)
  end

  def self.find_by(attribute)

    field_name = attribute.keys.first.to_s
    field_value = attribute.values[0]

    DB[:conn].execute("SELECT * FROM #{table_name} WHERE #{field_name} = '#{field_value}'")

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
    self.class.column_names.delete_if {|col| col == "id"}.join(", ")
  end

  def values_for_insert
    values = []

    self.class.column_names.each do |col_name|
      values << "'#{send(col_name)}'" unless send(col_name).nil?
    end
    values.join(", ")
  end

  def save
    table_name = self.table_name_for_insert
    col_names = self.col_names_for_insert
    vals = self.values_for_insert

    DB[:conn].execute("INSERT INTO #{table_name} (#{col_names}) VALUES (#{vals})")
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name}")[0][0]
  end

end
