require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord

  def self.table_name
    self.to_s.downcase.pluralize
  end

  def self.column_names
    DB[:conn].results_as_hash = hash

    sql = "PRAGMA table_info('#{table_name}')"

    table_info = DB[:conn].execute(sql)
    column_names = []
    table_info.each { |row| column_names << row['name'] }
    column_names.compact
  end

  def initialize(options={})
    options.each do |attribute, value|
      self.send("#{attribute}=", value)
    end
  end

  def table_name_for_insert
    self.class.table_name
  end

  def col_names_for_insert
    columns = []
    self.class.column_names.each { |col| columns << col unless col == 'id' }
    columns.join(", ")
  end

  def values_for_insert
    values = []
    self.class.column_names.each do |col|
      values << "'#{send(col)}'" unless col == 'id'
    end
    values.join(", ")
  end

  def save
    sql = "INSERT INTO #{table_name_for_insert} (#{col_names_for_insert})" \
           "VALUES (#{values_for_insert})"
    DB[:conn].execute(sql)

    @id = DB[:conn].last_insert_row_id
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM #{self.table_name} WHERE name = ?"
    DB[:conn].execute(sql, name)

  end

  def self.find_by(attr={})
    sql = ''
    attr.map do |k, v|
      sql = "SELECT * FROM #{table_name} WHERE #{k.to_s} = '#{v}'"
    end
    DB[:conn].execute(sql)
  end
end
