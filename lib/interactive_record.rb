require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord
  #table and attribute set up
  def self.table_name
    self.to_s.downcase.pluralize
  end

  def self.column_names
    DB[:conn].results_as_hash = true
    column_names = Array.new

    sql = <<-sql
      PRAGMA
      table_info('#{table_name}')
    sql

    table_info = DB[:conn].execute(sql)

    table_info.each {|row| column_names << row["name"]}

    column_names.compact
  end

  #initialize
  def initialize(hash = {})
    hash.each {|k,v| self.send("#{k}=", v)}
  end

  #class methods
  def self.find_by_name(name)
    sql = <<-sql
      SELECT *
      FROM
      #{self.table_name}
      WHERE
      name = '#{name}'
    sql

    DB[:conn].execute(sql)
  end

  def self.find_by(attribute_hash)
    value = attribute_hash.values.first
    formatted_value = value.class == Fixnum ? value : "'#{value}'"
    sql = "SELECT * FROM #{self.table_name} WHERE #{attribute_hash.keys.first} = #{formatted_value}"
    DB[:conn].execute(sql)
  end



  #instance methods
  def table_name_for_insert
    self.class.table_name
  end

  def col_names_for_insert
    self.class.column_names.delete_if {|col| col == "id"}.join(", ")
  end

  def values_for_insert
    values = Array.new
    self.class.column_names.each do |col_name|
      values << "'#{send(col_name)}'" unless send(col_name).nil?
    end
    values.join(", ")
  end

  def save
    sql = <<-sql
      INSERT INTO
      #{table_name_for_insert}
      (#{col_names_for_insert})
      VALUES
      (#{values_for_insert});
    sql

    id_pull = <<-sql
      SELECT
      last_insert_rowid()
      FROM
      #{table_name_for_insert};
    sql

    DB[:conn].execute(sql)

    self.id = DB[:conn].execute(id_pull)[0][0]
  end

end
