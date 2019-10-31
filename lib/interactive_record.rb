require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord
  
  def self.table_name
    self.to_s.downcase.pluralize
  end
  
  def self.column_names
    DB[:conn].results_as_hash = true
 
    sql = "PRAGMA table_info('#{table_name}')"
    column_names = []
    table_info = DB[:conn].execute(sql).each do |column|
      column_names << column["name"]
    end
    column_names.compact
  end 
  
  
  def initialize(options={})
    options.each do |property, value|
      self.send("#{property}=", value)
    end
  end
  
  def table_name_for_insert
    self.class.table_name
  end 
  
  def col_names_for_insert
    self.class.column_names.delete_if {|col| col == "id"}.join(", ")
  end 
  
  def values_for_insert
    values = []
    self.class.column_names.each do |col|
      values << "'#{send(col)}'" unless send(col).nil?
    end
    values.join(", ")
  end
  
  def save
    sql = <<-SQL
      INSERT INTO #{table_name_for_insert} (#{col_names_for_insert})
      VALUES (#{values_for_insert})
    SQL
    
    DB[:conn].execute(sql)
    
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  end 
  
  def self.find_by_name(name)
    sql = <<-SQL
      SELECT *
      FROM #{self.table_name}
      WHERE name = '#{name}'
    SQL
    DB[:conn].execute(sql)
  end 
  
  def self.find_by(attribute)
    #expect(Student.find_by({name: "Susan"}))
    #col = attribute.keysto_s
    column = attribute.to_a.join(', ').split(', ')
        sql = <<-SQL
            SELECT * FROM  #{table_name} 
            WHERE #{column[0]} = '#{column[1]}'
        SQL
        DB[:conn].execute(sql)
  end 
  
end