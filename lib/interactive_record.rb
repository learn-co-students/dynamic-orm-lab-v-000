require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'pry'

class InteractiveRecord

  def self.table_name
    self.to_s.downcase.pluralize
  end

  def self.column_names
    DB[:conn].results_as_hash = true

    sql = "PRAGMA TABLE_INFO('#{table_name}')"

    table_info = DB[:conn].execute(sql)
    column_names = []
    table_info.each do |row|
      column_names << row["name"]
    end
    column_names.compact
  end

  def initialize(options = {})
    options.each do |key, val|
      self.send("#{key}=", val)
    end
  end

  def save
    sql = <<-SQL
    INSERT INTO #{table_name_for_insert} (#{col_names_for_insert})
    VALUES (#{values_for_insert})
    SQL
    DB[:conn].execute(sql)
    sql2 = <<-SQL
    SELECT last_insert_rowid()
    FROM #{table_name_for_insert}
    SQL
    @id = DB[:conn].execute(sql2)[0][0]
  end

  def table_name_for_insert
    self.class.table_name
  end

  def values_for_insert
    values = []
    self.class.column_names.each do |this_col|
      values.push("'#{send(this_col)}'") unless send(this_col).nil?
    end
    values.join(", ")
  end

  def col_names_for_insert
    self.class.column_names.delete_if {|col| col == "id"}.join(", ")
  end

  def self.find_by(search_hash)
    key = search_hash.keys.first.to_s
    val = search_hash.values.first
    new_val = val.class==Fixnum ? val : "'#{val}'"
    sql = <<-SQL
    SELECT *
    FROM #{self.table_name}
    WHERE #{key} = #{new_val}
    SQL
    DB[:conn].execute(sql)
  end

  def self.find_by_name(name)
    sql = <<-SQL
    SELECT *
    FROM #{self.table_name}
    WHERE name = '#{name}'
    SQL
    DB[:conn].execute(sql)
  end

end
