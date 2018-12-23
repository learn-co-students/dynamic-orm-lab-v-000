require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'pry'

class InteractiveRecord
  def self.table_name
    self.to_s.downcase.pluralize
  end

  def self.column_names
    DB[:conn].results_as_hash = true

    sql = "PRAGMA table_info('#{table_name}');"

    raw_table_headers = DB[:conn].execute(sql)
    table_headers = Array.new

    raw_table_headers.each do |column|
      table_headers << column["name"]
    end

    table_headers.compact
  end

  def initialize(attributes = {})
    attributes.each do |attribute, value|
      self.send("#{attribute}=", value)
    end
  end

  def table_name_for_insert
    self.class.table_name
  end

  def col_names_for_insert
    self.class.column_names.delete_if { |column| column == "id" }.join(", ")
  end

  def values_for_insert
    values = Array.new

    self.class.column_names.each do |column|
      values << "'#{self.send(column)}'" unless send(column).nil?
    end

    values.join(", ")
  end

  def save
    sql = <<-SQL
      INSERT INTO #{table_name_for_insert} (#{col_names_for_insert})
      VALUES (#{values_for_insert});
    SQL

    DB[:conn].execute(sql)

    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT *
      FROM #{self.table_name}
      WHERE name = ?;
    SQL

    DB[:conn].execute(sql, name)
  end

  # def self.find_by(hash)
  #   key = hash.keys[0].to_s
  #   value_0 = hash.values[0]
  #   value = value_0.is_a?(Integer) ? value_0 : "'#{value_0}'"
  #
  #   sql = <<-SQL
  #     SELECT *
  #     FROM #{self.table_name}
  #     WHERE ? = ?;
  #   SQL
  #
  #   DB[:conn].execute(sql, key, value)
  # end

  def self.find_by(hash)
    key = hash.keys[0]
    value_0 = hash.values[0]
    value = value_0.is_a?(Integer) ? value_0 : "'#{value_0}'"

    sql = <<-SQL
      SELECT *
      FROM #{self.table_name}
      WHERE #{key} = #{value};
    SQL

    DB[:conn].execute(sql)
  end
end
