require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord

  def initialize(attributes={})
    attributes.each do |key, value|
      self.send("#{key}=", value)
    end
  end

  def self.table_name
    self.to_s.downcase.pluralize
  end

  def self.column_names
    sql = "PRAGMA table_info(#{table_name})"
    table_info = DB[:conn].execute(sql)
    table_info.collect do |col_hash|
      col_hash["name"]
    end.compact
  end

  def table_name_for_insert
    self.class.table_name
  end

  def col_names_for_insert
    self.class.column_names.delete_if {|col_name| col_name == "id"}.join(", ")
  end

  def values_for_insert
    self.class.column_names.collect do |col_name|
      col_name == id ? nil : "\'#{self.send("#{col_name}")}\'"
    end.compact.join(", ").gsub("\'\',", "").strip
  end

  # def save
  #   if self.id.nil?
  #     DB[:conn].execute("INSERT INTO ? (?) VALUES (?);", self.table_name_for_insert, self.col_names_for_insert, self.values_for_insert)
  #     id = DB[:conn].execute('SELECT last_insert_rowid() FROM ?;', self.table_name_for_insert)[0][0]
  #   else
  #   end
  # end

  def save
    sql = "INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})"
    DB[:conn].execute(sql)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  end

  # def self.find_by_name(name)
  #   DB[:conn].execute('SELECT * FROM ? WHERE name = ?;', self.table_name, name)
  # end

  def self.find_by_name(name)
    sql = "SELECT * FROM #{self.table_name} WHERE name = '#{name}'"
    DB[:conn].execute(sql)
  end

  # def self.find_by(hash)
  #   DB[:conn].execute('SELECT * FROM ? WHERE ? = ?;', self.table_name, hash.keys[0].to_s, hash[hash.keys[0]].to_s)
  # end

  def self.find_by(hash)
    DB[:conn].execute("SELECT * FROM #{self.table_name} WHERE #{hash.keys[0].to_s} = '#{hash[hash.keys[0]]}';")
  end

end
