require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord

  def self.table_name
    self.to_s.downcase.pluralize
  end

  def self.column_names
    DB[:conn].results_as_hash = true
    cols = DB[:conn].execute("PRAGMA table_info(#{self.table_name})")
    col_names = []
    cols.each do |col|
      col_names << col["name"].to_s
    end
    col_names
  end

  def self.find_by_name(name)
    DB[:conn].execute("SELECT * FROM #{self.table_name} WHERE name='#{name}'")
  end

  def self.find_by(hash)
    #convert each to "key=value" strings separated by commas
    array = []
    hash.each do |key,value|
      array << "#{key}= '#{value}'"
    end

    find = array.join(", ")

    sql = <<-SQL
      SELECT * FROM #{self.table_name}
      WHERE #{find};
    SQL
    DB[:conn].execute(sql)
  end

  ##INSTANCE METHODS##

  def initialize(hash={})
    hash.each do |key,value|
      self.send("#{key}=",value)
    end
  end

  def save
    sql = <<-SQL
      INSERT INTO #{self.table_name_for_insert}(#{self.col_names_for_insert})
      VALUES (#{self.values_for_insert});
    SQL
    DB[:conn].execute(sql)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{self.table_name_for_insert}")[0][0]
  end

  def table_name_for_insert
    self.class.table_name
  end

  def col_names_for_insert
    out = self.class.column_names.delete_if { |e| e=='id' }
    out.join(", ")
  end

  def values_for_insert
    out = []
    self.class.column_names.each do |c|
      out << "'#{self.send(c)}'" unless self.send(c).nil?
    end
    out.join(", ")
  end

end
