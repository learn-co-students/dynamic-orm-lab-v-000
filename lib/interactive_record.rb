require_relative "../config/environment.rb"
require 'pry'
require 'active_support/inflector'

class InteractiveRecord

  def initialize(options = {})
    options.each do | key, value |
      self.send("#{key}=", value)
    end
  end

  def self.table_name
    self.to_s.downcase.pluralize
  end

  def self.column_names
    return_array = []
    sql = <<-SQL
      PRAGMA table_info(#{table_name})
    SQL

    DB[:conn].execute(sql).each do | el |
      return_array << el["name"]
    end
    return_array.compact
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
    sql = <<-SQL
    INSERT INTO #{table_name_for_insert} (#{col_names_for_insert})
    VALUES (#{values_for_insert})
    SQL

    DB[:conn].execute(sql)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM #{self.table_name} WHERE name = ?
    SQL

    DB[:conn].execute(sql, name)
  end

  def self.find_by(hash)
    key = hash.keys[0].to_s
    value = hash[hash.keys[0]]

    # binding.pry
    DB[:conn].execute("SELECT * FROM #{self.table_name}") # WHERE ? = ?", key, value)
  end

end
