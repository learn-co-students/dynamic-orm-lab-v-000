require_relative "../config/environment.rb"
#require 'active_support/inflector'

class InteractiveRecord

  def self.table_name
    self.to_s.downcase + "s"
  end

  def self.column_names
    table = DB[:conn].execute("PRAGMA table_info('#{self.table_name}')")
    table.map {|row| row["name"]}.compact
  end

  def table_name_for_insert
    self.class.table_name
  end

  def col_names_for_insert
    result = []
    self.class.column_names.each {|col| result << col unless col == "id"}
    result.join(", ")
  end

  def values_for_insert
    result = []
    self.class.column_names.each {|col| result << "'#{send(col)}'" unless send(col).nil?}
    result.join(", ")
  end

  def save
    sql = "INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})"
    DB[:conn].execute(sql)

    self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM #{table_name} WHERE #{table_name}.name = ?"
    DB[:conn].execute(sql, name)
  end

  def self.find_by(data_hash)
    attribute = data_hash.keys[0].to_s
    value = data_hash.values[0].to_s
    sql = "SELECT * FROM #{table_name} WHERE #{attribute} = '#{value}'"
    DB[:conn].execute(sql)
  end
end
