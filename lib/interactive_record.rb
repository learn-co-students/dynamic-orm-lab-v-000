require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord
  def self.table_name
    self.to_s.downcase.pluralize
  end

  def self.column_names
    sql = "pragma table_info(#{table_name})"
    table_info = DB[:conn].execute(sql)
    col_names = []

    table_info.each{ |col|
      col_names << col["name"]
    }
    col_names.compact
  end

  def initialize(opt={})
    opt.each{ |prop, value|
      self.send("#{prop}=",value)
    }
  end

  def table_name_for_insert
    self.class.table_name
  end

  def col_names_for_insert
    self.class.column_names.delete_if { |col| col == 'id' }.join(', ')
  end

  def values_for_insert
    values = []
    self.class.column_names.each{ |col|
      values << "'#{send(col)}'" unless send(col).nil?
      }
    values.join(', ')
  end

  def save
    sql = "insert into #{table_name_for_insert} (#{col_names_for_insert}) values (#{values_for_insert})"
    DB[:conn].execute(sql)
    @id = DB[:conn].execute("select last_insert_rowid() from #{table_name_for_insert}")[0][0]
  end

  def self.find_by_name(name)
    sql = <<-sql
      select * from #{table_name}
      where name = ?
      sql
    DB[:conn].execute(sql,name)
  end

  def self.find_by(hash)
    sql = <<-sql
      select * from #{table_name}
      where #{hash.keys[0].to_s} = ?
    sql
    #DB[:conn].execute(sql, 'name', 'susan' )
    DB[:conn].execute(sql, hash.values[0] )
  end

end
