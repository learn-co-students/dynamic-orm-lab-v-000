require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord

  def self.table_name
    self.to_s.downcase.pluralize
  end

  def self.column_names
    sql = "PRAGMA table_info(#{self.table_name})"
    col_names = []
    DB[:conn].execute(sql).each do |col|
      col_names << col["name"]
    end
    col_names
  end

  def initialize(attributes = {})
    attributes.each do |attr, value|
      self.send("#{attr}=", value)
    end
  end

end
