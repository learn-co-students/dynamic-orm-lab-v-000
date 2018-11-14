require_relative "../config/environment.rb"
require 'active_support/inflector'


class InteractiveRecord
  def self.table_name
    self.to_s.downcase.pluralize
  end

  def self.column_names
    sql = "pragma table_info('#{table_name}')"

    table_info = DB[:conn].execute(sql)
    columns = [ ]
    table_info.each do |row|
      columns << row["name"]
    end
    columns.compact
  end

  def self.find_by_name(name)

  end

  def self.find_by(attr)

  end

  def initialize(options = {})
    options.each do |property, value|
      self.send("#{property}=", value)
    end
  end

  def table_name_for_insert
    self.class.table_name
  end

  def col_names_for_insert
    self.class.column_names.delete_if{|x| x == "id"}.join(", ")
  end

  def values_for_insert
    values = [ ]

    self.class.column_names.each do |col|
      values << ("'#{send(col)}'") unless send(col).nil?
    end
    values.join(", ")
  end

  def save

  end


end
