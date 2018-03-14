require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord

  def initialize(args = {})
    args.each {|key, value| self.send("#{key}=", value)}
  end

  def self.table_name
    self.to_s.downcase.pluralize
  end

  def self.column_names
    sql = "PRAGMA table_info(#{self.table_name})"
    table_info = DB[:conn].execute(sql)
    fields = []

    table_info.each do |column|
      fields << column["name"]
    end
    fields.compact
  end

  def table_name_for_insert
    self.class.table_name
  end

  def col_names_for_insert
    self.class.column_names.delete_if {|c| c == "id"}.join(", ")
  end

  def values_for_insert
    self.class.column_names.collect do |variable|
      self.send(variable) ? "'#{self.send(variable)}'" : nil
    end.compact.join(", ")
  end

  def variables_to_hash
    self.class.column_names.collect do |variable|
      [variable, self.send(variable)]
    end.to_h
  end

  def save
    self.class.find_by_name(self.name)
    sql = "INSERT INTO #{self.table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})"
      DB[:conn].execute(sql)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}").first["last_insert_rowid()"]
      self
    end

  def self.find_by_name(column_name)
    self.find_by({name: column_name})
  end


  def self.find_by(parameters)
    where = self.build_atrribution_or_conditional(parameters)
    sql = "SELECT * FROM #{self.table_name} WHERE #{where}"
    DB[:conn].execute(sql)
 end

 def self.build_atrribution_or_conditional(parameters, join = "AND")
   parameters.collect do |parameter, value|
     value.class == String ? "#{parameter} = '#{value}'" : "#{parameter} =  #{value}"
   end.join(join)
 end

end
