require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord

  def initialize(options={})
    options.each do |property, value|
      self.send("#{property}=", value)
    end
  end

  def self.table_name
    self.to_s.downcase.pluralize
  end

  def self.column_names
    DB[:conn].results_as_hash = true

    sql = "pragma table_info('#{table_name}')"
    table_data = DB[:conn].execute(sql)
    column_names = []

    table_data.each do |hash|
      column_names << hash["name"]
    end
    column_names.compact
  end

  def col_names_for_insert
    self.class.column_names.delete_if do
      |col_name| col_name == "id"
    end.join(", ")
  end

  def table_name_for_insert
    self.class.table_name
  end

  def values_for_insert
    values = []
    self.class.column_names.each do |col_name|
      values << "'#{send(col_name)}'" unless send(col_name).nil?
    end
    values.join(", ")
  end

  def save
    sql = <<-SQL
      INSERT INTO #{table_name_for_insert} (#{col_names_for_insert})
      VALUES (#{values_for_insert})
    SQL
    DB[:conn].execute(sql)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT *
      FROM #{self.table_name}
      WHERE name = "#{name}"
      SQL
      DB[:conn].execute(sql)
  end

  def self.find_by(attributes_hash)
    value = attributes_hash.values.first
    formatted_value = value.class == Fixnum ? value : "'#{value}'"
    sql = "SELECT * FROM #{self.table_name} WHERE #{attributes_hash.keys.first} = #{formatted_value}"
    DB[:conn].execute(sql)
  end

end
