require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord

  def self.table_name
    self.to_s.downcase.pluralize
  end
  
  def self.column_names
    # get table names via query
    # parse for the column names
    DB[:conn].results_as_hash = true

    sql = "pragma table_info(#{table_name})"
    table_info = DB[:conn].execute(sql)
    table_info.map { |row| row["name"] }.compact 
  end
  
  def table_name_for_insert
    self.class.table_name
  end

  def col_names_for_insert
    self.class.column_names.reject{|col| col == "id"}.join(", ")
  end

  def values_for_insert
    self.class.column_names.reject{|col| col == "id"}.map {|col| "'#{send(col)}'"}.join(", ")
  end

  def save
    sql = <<-SQL
      INSERT INTO #{table_name_for_insert}(#{col_names_for_insert})
      VALUES (#{values_for_insert})
    SQL

    DB[:conn].execute(sql) 
    self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  end

  def self.find_by_name(name)
    DB[:conn].results_as_hash = true
    sql = <<-SQL
      SELECT * FROM #{table_name}
      WHERE name = ?
    SQL

    DB[:conn].execute(sql, name)
  end

  def self.find_by(opt = {})
    DB[:conn].results_as_hash = true
    col_name = opt.keys.first.to_s
    sql = <<-SQL
      SELECT * FROM #{table_name}
      WHERE #{col_name} = ? 
    SQL
    
    DB[:conn].execute(sql, opt.values.first)

  end
end
