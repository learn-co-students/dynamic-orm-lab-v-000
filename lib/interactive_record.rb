require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'pry'

class InteractiveRecord
  attr_accessor :name, :grade, :id

  def initialize(id:,name:,grade:)
    @name = name,
    @grade = grade,
    @id = id
    new_student = Student.new(id,name,grade)
  end

  def self.table_name
    self.to_s.downcase.pluralize
  end

  def self.column_names
    sql = <<-sql
      PRAGMA TABLE_INFO("#{self.table_name}")
    sql
    raw_info = DB[:conn].execute(sql)
    retrieved_column_names = []
    raw_info.each do |row_hash|
      retrieved_column_names << row_hash["name"]
    end
    retrieved_column_names.compact
  end

  def table_name_for_insert
    self.class.to_s.downcase.pluralize
  end

  def col_names_for_insert
    names_for_insert = []
    self.class.column_names.each do |name|
      names_for_insert << "#{name}" unless send(name).nil?
    end
    names_for_insert.join(", ")
  end

  def values_for_insert
    values_for_insert = []
    self.class.column_names.each do |value|
      values_for_insert << "'#{send(value)}'" unless send(value).nil?
    end
    values_for_insert.join(", ")
  end

  def save
    sql = <<-sql
      INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) 
      VALUES (#{values_for_insert})
    sql
    DB[:conn].execute(sql)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  end

  def self.table_name_for_class
    self.to_s.downcase.pluralize
  end

  def self.find_by_name(name)
    sql = <<-sql
      SELECT * FROM #{table_name_for_class} WHERE name = '#{name}'
    sql
    DB[:conn].execute(sql)
  end

  def self.find_by(hash)
    sql = <<-sql
      SELECT * FROM #{table_name_for_class} WHERE #{hash.keys[0].to_s} = '#{hash[hash.keys[0]]}'
    sql
    DB[:conn].execute(sql)
  end
end


