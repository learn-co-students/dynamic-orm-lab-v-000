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

      table_info = DB[:conn].execute(sql)
      column_names = []
      table_info.each {|row| column_names << row["name"]}
      column_names.compact
  end

  def initialize(options={})
    options.each do |key, value|
      self.send("#{key}=", value)
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
    if self.id
    else
      sql = <<-SQL
        INSERT INTO #{table_name_for_insert}
        (#{col_names_for_insert}) VALUES (#{values_for_insert})
      SQL

      DB[:conn].execute(sql)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
    end
  end

  def self.find_by_name(x)
    sql = <<-SQL
    SELECT * FROM #{self.table_name}
    WHERE name = ?
    SQL

    DB[:conn].execute(sql,x)
  end

  def self.find_by(hash)
    atr = hash.keys.first
    val =  hash.values.first
      sql = <<-SQL
      SELECT * FROM #{self.table_name}
      WHERE #{atr} = ?
    SQL
    DB[:conn].execute(sql, val)
  end

end
