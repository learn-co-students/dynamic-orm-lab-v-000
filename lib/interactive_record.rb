require 'pry'
require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord

  def self.table_name
    self.to_s.downcase.pluralize
  end

  def self.column_names
    column_names = []
    table_info = DB[:conn].execute("PRAGMA table_info('#{table_name}')")
    table_info.each do | column |
        column_names << column["name"]
    end
    column_names
  end

  def initialize(attributes={})
    attributes.each do | attribute, value |
        self.send("#{attribute}=", value)
    end
  end

  def table_name_for_insert
    self.class.table_name
  end

  def col_names_for_insert
    self.class.column_names.delete_if{ | entry | entry == "id" }.join(", ")
  end

  def question_marks_for_insert
    (self.class.column_names.size-1).times.collect {"?"}.join(", ")
  end

  def values_for_insert
    values = []
    self.class.column_names.each do | col_name | 
        values << send(col_name) unless send(col_name).nil?
    end
    values
  end

  def save
    # DB[:conn].execute("INSERT INTO #{self.class.table_name} (#{col_names_for_insert}) VALUES (#{values_for_insert})")
    sql = <<-SQL
      INSERT INTO #{self.class.table_name} (#{col_names_for_insert}) VALUES (#{question_marks_for_insert})
    SQL
    DB[:conn].execute(sql, *values_for_insert)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{self.class.table_name}")[0][0]
  end

  def self.find_by_name(name)
    DB[:conn].execute("SELECT * FROM #{self.table_name} WHERE name = ?", name)
  end

  def self.find_by(attribute={})
    DB[:conn].execute("SELECT * FROM #{self.table_name} WHERE #{attribute.keys.first} = '#{attribute.values.first}'")
  end
end