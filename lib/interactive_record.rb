require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'pry'
class InteractiveRecord
  def self.table_name
    self.to_s.downcase.pluralize
  end

  def self.column_names  #=> ["id", "name", "grade"]
    DB[:conn].results_as_hash = true #don't know why we put it here again...
    sql = "PRAGMA table_info(#{self.table_name})"
    table_info = DB[:conn].execute(sql)
    column_names = []
    table_info.each do |column|
      column_names << column["name"]
    end

    column_names.compact

    ## my basic version
    # DB[:conn].execute("PRAGMA table_info(#{self.table_name})").map do |elem|
    #   elem["name"]
    # end
  end

  # want to be able to do: student = Student.new(name: "Kevin", grade: 12)
  # will only work if there are corresponding attr_accessor for every key
  # which gets taken care of by col_names method in the Student Class.
  def initialize(options = {})
    options.each do |key, value|
      self.send("#{key}=", value)
    end
  end

  def table_name_for_insert #students
    self.class.table_name
  end

  def col_names_for_insert #name, grade
    self.class.column_names.delete_if {|col| col == "id"}.join(", ")

    #my code: clever use of drop, but soln reads better.
      #self.class.column_names.drop(1).join(", ")
  end

  def values_for_insert #"'Sam', '11'"
    values = []
    self.class.column_names.each do |column| # ["id", "name", "grade"]
      values << "'#{send(column)}'" unless send(column).nil?
      #calls the attr_reader for every loop, unless the reader method
      #returns nil, which would be the case for the id.
      #the record is not saved yet at this point.
    end
    values.join(", ")
  end

  def save
    sql = <<-SQL
      INSERT INTO #{table_name_for_insert}(#{col_names_for_insert})
      VALUES (#{values_for_insert})
    SQL
    DB[:conn].execute(sql)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  end

  # What last four methods have built up to.
  # sql = <<-SQL
  #   INSERT INTO table(val1, val2) VALUES (?,?)
  # SQL
  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM #{self.table_name}
      WHERE name = ?
    SQL
    # can't mix class methods with instance methods. MUST BE self.table_name
    # NOT table_name_for_insert
    DB[:conn].execute(sql, name)
  end

  def self.find_by(attribute)
    # binding.pry
    sql = <<-SQL
      SELECT * FROM #{self.table_name}
      -- WHERE #{attribute.keys.first.to_s} = #{attribute.values.first}
      WHERE "name" = "Susan"
    SQL
    # binding.pry
    DB[:conn].execute(sql)
  end




end
