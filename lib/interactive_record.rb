require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord

  def self.table_name
    self.to_s.downcase.pluralize
  end

  def self.column_names
    DB[:conn].results_as_hash = true

    sql = "pragma table_info ('#{table_name}')"
    DB[:conn].execute(sql).map do |record|
      record["name"]
    end.compact
  end

  def self.create_attributes_from_columns
    self.column_names.each do |col_name|
      attr_accessor col_name.to_sym
    end
  end

  def initialize(options={})
    # create attributes
    self.class.create_attributes_from_columns

    # initialize attributes
    options.each do |property, value|
      self.send("#{property}=", value)
    end
  end

  def table_name_for_insert
    self.class.table_name
  end

  def col_names_for_insert
    self.class.column_names.delete_if do |col_name|
      col_name == "id"
    end.join(", ")
  end

  def values_for_insert
    self.class.column_names.map do |col_name|
      "'#{send(col_name)}'" unless send(col_name).nil?
    end.compact.join(", ")
  end

  def save
    sql = <<-SQL
      INSERT INTO #{table_name_for_insert} (#{col_names_for_insert})
      VALUES (#{values_for_insert})
    SQL

    DB[:conn].execute(sql)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert};")[0][0]
  end

  def self.find_by(attr_to_find)
    attr_name = attr_to_find.keys.first
    attr_value = attr_to_find.values.first
    sql = <<-SQL
      SELECT *
      FROM #{self.table_name}
      WHERE #{attr_name} = ?
    SQL

    DB[:conn].execute(sql, attr_value)
  end

  def self.find_by_name(name_to_find)
    sql = <<-SQL
      SELECT *
      FROM #{table_name}
      WHERE name = ?
    SQL

    DB[:conn].execute(sql, name_to_find)
  end

end
