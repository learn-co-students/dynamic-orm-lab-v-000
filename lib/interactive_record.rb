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
    table_info.each do |row|
      column_names << row["name"]
    end
    column_names.compact
  end

  self.column_names.each do |col|
    attr_accessor col.to_sym
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM #{table_name} WHERE name= '#{name}';"
    DB[:conn].execute(sql)
  end

  def initialize(attrs={})
    attrs.each do |key,value|
      self.send(("#{key}="),value)
    end
  end

  def save
    sql = "INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert});"
    DB[:conn].execute(sql)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert};")[0][0]
  end

  def table_name_for_insert
    self.class.table_name
  end

  def col_names_for_insert
    self.class.column_names.delete_if {|col| col == "id"}.join(", ")
  end

  def values_for_insert
    values = []
    self.class.column_names.each do |col|
      values << "'#{send(col)}'" unless send(col).nil?
    end
    values.join(", ")
  end

  def self.find_by(arg)
    results = []
    arg.each do |key,value|
      sql = "SELECT * from #{table_name} WHERE #{key}='#{value}'"
      results << DB[:conn].execute(sql)
    end
    results[0]
    # key = arg.keys.first
    # value = arg[key]
    # # if key == 'Susan' || value == 'Susan'
    # #   binding.pry
    # # end
    # sql = "SELECT * FROM #{table_name} WHERE #{key}=#{value};"
    # binding.pry
    # DB[:conn].execute(sql)
  end
end