require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord

  def self.table_name
    self.to_s.pluralize.downcase
  end

  def self.column_names
    sql = "PRAGMA table_info(#{self.table_name});"

    columns_data = DB[:conn].execute(sql)

    columns_data.map do |row|
      row["name"]
    end
  end

  def initialize(options={})
    options.each do |property, value|
      self.send("#{property}=", value)
    end
  end

  def save
    sql = "INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})"

    DB[:conn].execute(sql)

    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  end

  def table_name_for_insert
    self.class.table_name
  end

  def values_for_insert
    values = []

    self.class.column_names.map do |col_name|
      values << "'#{send(col_name)}'" unless send(col_name).nil?
    end

    values.join(", ")
  end

  def col_names_for_insert
    self.class.column_names.delete_if {|col| col == "id"}.join(", ")
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM #{self.table_name} WHERE name = '#{name}'"

    DB[:conn].execute(sql)
  end

  def self.find_by(attribute_hash)
    columns = self.column_names

    results = columns.map do |col_name|
      sql = "SELECT * FROM #{self.table_name} WHERE #{col_name} = #{attribute_hash.keys[0]}"

      DB[:conn].execute(sql)
    end

    results.delete_if {|element| element.empty?}.flatten
  end

end
