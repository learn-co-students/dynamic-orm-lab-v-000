require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'pry'

class InteractiveRecord
  def self.table_name
    self.to_s.downcase.pluralize
  end

  def self.column_names
    DB[:conn].results_as_hash = true

    sql = "pragma table_info('#{table_name}')"
    DB[:conn].execute(sql).map { |row| row["name"] }.compact
  end

  def initialize(options = {})
    options.each { |property, value| self.send("#{property}=", value) }
  end

  def table_name_for_insert
    self.class.table_name
  end

  def col_names_for_insert
    self.class.column_names.delete_if { |col_name| col_name == "id"}.join(", ")
  end

  # INSERT INTO table (name, age) VALUES (name, age)

  def values_for_insert
    self.class.column_names.map do |col_name|
      "'#{send(col_name)}'" unless send(col_name).nil?
    end.compact.join(", ")
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
    DB[:conn].execute("SELECT * FROM #{self.table_name} WHERE name = '#{name}'")
  end

  def self.find_by(a)
    sql = "SELECT * FROM #{self.table_name} WHERE #{a.keys.first} = '#{a.values.first }';"
    DB[:conn].execute(sql)
  end

end
