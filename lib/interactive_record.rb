require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord
  def initialize(attributes={})
    attributes.each { |key, value| self.send("#{key}=",value) unless value.nil?}
  end

  def save
    sql = <<-SQL
    INSERT INTO #{table_name_for_insert}(#{col_names_for_insert}) VALUES (#{values_for_insert})
    SQL

    DB[:conn].execute(sql)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  end

  def self.find_by_name(name)
    sql = <<-SQL
    SELECT * FROM #{table_name} WHERE name = ?
    SQL

    DB[:conn].execute(sql, name)


  end

  def self.table_name
    self.to_s.downcase.pluralize
  end

  def table_name_for_insert
    self.class.table_name
  end

  def self.column_names
    sql = <<-SQL
    pragma table_info('#{table_name}')
    SQL
    columns = []
    data = DB[:conn].execute(sql)
    data.each {|attribute| columns << attribute["name"] }
    columns
  end

  def col_names_for_insert
    self.class.column_names.delete_if {|column| column == "id"}.join(", ")
  end

  def values_for_insert
    values = []
    self.class.column_names.each {|property| values << "'#{self.send(property)}'" unless send(property).nil?}
    values.join(", ")
  end

  def self.find_by(attributes)
    sql = <<-SQL
    SELECT * FROM #{table_name} WHERE name = ? OR grade = ?
    SQL

    DB[:conn].execute(sql, attributes[:name], attributes[:grade].to_i)
  end





end
