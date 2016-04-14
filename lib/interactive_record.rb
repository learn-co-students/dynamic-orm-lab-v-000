require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'pry'
class InteractiveRecord
  def self.find_by_name

  end

  def table_name_for_insert

  end

  def self.column_names
    column_names= []
    sql = <<-SQL
      pragma table_info('#{table_name}')
    SQL
    table_info = DB[:conn].execute(sql)
    table_info.map do |row|
      column_names << row["name"]
    end
    column_names.compact
  end

  def self.table_name
    self.to_s.downcase.pluralize
  end

  def save

  end

  def initialize(attributes)
binding.pry
    attributes.each do |key, value|
      self.send("#{key}=", nil)
    end
    binding.pry
  end

  self.column_names.each do |col_name|
    attr_accessor col_name.to_sym
  end

end
#DB[:conn].execute()
