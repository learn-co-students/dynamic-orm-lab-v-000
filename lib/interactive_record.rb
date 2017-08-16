require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord
  def self.table_name
    self.to_s.downcase.pluralize
  end

  def self.column_names
    DB[:conn].results_as_hash = true

    sql = <<-SQL
    PRAGMA table_info('#{table_name}')
    SQL
    table_data = DB[:conn].execute(sql)
    table_data.map do |row|
      row["name"]
    end.compact
  end

  def initialize(hash={})
    hash.each {|property, value| self.send("#{property}=", value) }
  end

  def table_name_for_insert
    self.class.table_name
  end

  def col_names_for_insert
    self.class.column_names.reject {|column_name| column_name == "id"}.join(", ")
  end

  def values_for_insert
    values = []
    self.class.column_names.select do |column_name|
     values << "'#{send(column_name)}'" unless send(column_name).nil?
    end
    values.join(", ")
  end

  def save
    sql = <<-SQL
      INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (
        #{values_for_insert}
      )
    SQL

    DB[:conn].execute(sql)

    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * from #{self.table_name} WHERE name = ?
    SQL

    DB[:conn].execute(sql, name)
  end

  def self.find_by(hash)
    value = if hash.values.first.class == Fixnum
                hash.values.first
              else
                hash.values.first.to_s
              end
    sql = <<-SQL
      SELECT * FROM #{self.table_name} WHERE #{hash.keys.first} = ?
    SQL

    DB[:conn].execute(sql, value)
  end
end
