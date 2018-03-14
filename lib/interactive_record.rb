require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord
  def initialize

  end

  def self.table_name
    self.to_s.downcase.pluralize
  end

  def self.column_names
    DB[:conn].results_as_hash = true
    sql = "PRAGMA table_info('#{self.table_name}')"
    names = DB[:conn].execute(sql)
    column_names = []
    names.each { |row| column_names << row["name"]}
    column_names.compact
  end

  def initialize(options={})
    options.each { |property, value| self.send("#{property}=", value)}
  end

  def table_name_for_insert
    self.class.table_name
  end

  def col_names_for_insert
    column_names = self.class.column_names.delete_if{ |e| e == "id"}
    column_names.join(", ")
  end

  def values_for_insert
    values = []
    self.class.column_names.each {|col_name|
    values << "'#{send(col_name)}'" unless send(col_name).nil?}
    values.join(', ')
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
            FROM #{table_name}
            WHERE name = ?
            SQL
    data = DB[:conn].execute(sql, name)
  end

  def self.find_by(attribute)
    sql = ""
    attribute.each {|key, value|
    if value.is_a? String
      value = "'#{value}'"
    end
    sql = <<-SQL
              SELECT * FROM #{self.table_name}
              WHERE #{key.to_s} = #{value}
              SQL
    }
    DB[:conn].execute(sql)
  end

end
