require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'pry'

class InteractiveRecord

  def initialize(attributes={})
    attributes.each do |property,value|
      self.send("#{property}=",value)
    end
    self
  end

  def self.column_names
    DB[:conn].results_as_hash = true

    sql = "PRAGMA table_info('#{table_name}')"

    table_info = DB[:conn].execute(sql)
    column_names = []
    table_info.each do |row|
      column_names << row["name"]
    end
    column_names.compact
  end

  def self.table_name
    self.name.downcase.pluralize
  end

  def self.find_by_name(name)
    # sql = <<-SQL
    #       SELECT *
    #       FROM ?
    #       WHERE name = ?;
    #       SQL
    # DB[:conn].execute(sql, self.table_name, name)

    DB[:conn].execute("SELECT * FROM #{self.table_name} WHERE name = \"#{name}\";")
  end

  def self.find_by(attribute_hash)
    # sql = <<-SQL
    #         SELECT *
    #         FROM ?
    #         WHERE ? = ?;
    #         SQL
    # DB[:conn].execute(sql, self.table_name, attribute_hash.keys.first.to_s, attribute_hash[attribute_hash.keys.first])

    DB[:conn].execute("SELECT * FROM #{self.table_name} WHERE #{attribute_hash.keys.first.to_s} = \"#{attribute_hash[attribute_hash.keys.first]}\";")
  end

  def save
    # #binding.pry
    # table_name = self.table_name_for_insert
    # col_names = self.col_names_for_insert
    # values = self.values_for_insert
    # #binding.pry
    # stmt = DB[:conn].prepare("INSERT INTO ? (?) VALUES (?);")
    # stmt.bind_params(table_name, col_names, values)
    # #binding.pry
    # DB[:conn].execute(stmt)
    # sql = <<-SQL
    #       SELECT last_insert_rowid()
    #        FROM ?;
    #        SQL
    # @id = DB[:conn].execute(sql, self.table_name_for_insert)[0][0]

    DB[:conn].execute("INSERT INTO #{self.table_name_for_insert} (#{self.col_names_for_insert}) VALUES (#{self.values_for_insert});")
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{self.table_name_for_insert}")[0][0]
    # #binding.pry

  end

  def table_name_for_insert
    self.class.name.downcase.pluralize
  end

  def col_names_for_insert
    DB[:conn].results_as_hash = true

    sql = "PRAGMA table_info('#{table_name_for_insert}')"

    table_info = DB[:conn].execute(sql)
    col_names_for_insert = []
    table_info.each do |row|
      col_names_for_insert << row["name"]
    end
    col_names_for_insert.compact.delete_if{|col_name| col_name == 'id'}.join(', ')
  end

  def values_for_insert
    # self.column_names.each do |col_name|
    #   attr_accessor col_name.to_sym
    # end
    attr_array = []
    instance_variables.each do |attr_symbol|
      attr_array << attr_symbol.to_s
    end
    attr_array.delete_if {|attr_string|attr_string == "@id"}
    array_without_at_sign = attr_array.collect do |attr_string| 
      attr_string[0] = ''
      attr_string
    end
    array_of_values = array_without_at_sign.map do |attr_string|
      self.send("#{attr_string}")
    end

    array_of_values_with_single_quotes = array_of_values.collect do |value|
      "'#{value}'"
    end
    array_of_values_with_single_quotes.join(', ')
    #binding.pry
  end
end