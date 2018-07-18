require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord

  def self.table_name
    self.to_s.downcase.pluralize
  end

  def self.column_names
    DB[:conn].results_as_hash = true

    sql = "PRAGMA table_info('#{table_name}')"
    hash = DB[:conn].execute(sql)
    hash.map do |row|
      row["name"]
    end
  end

  def initialize(hash={})
    hash.each do |key, value|
      self.send("#{key}=", value)
    end
  end

  def table_name_for_insert
    self.class.table_name
  end

  def col_names_for_insert
    array = self.class.column_names
    new_array = []
    array.each do |attr|
      if attr != "id"
      new_array << attr
      end
    end
    new_array.join(", ")
  end

  def values_for_insert

  end 
end
