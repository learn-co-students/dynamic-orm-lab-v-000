require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord
  
  def initialize(options = {})
    options.each do |k, v|
      self.send("#{k}=", v)
    end
  end

  def self.table_name
    self.to_s.downcase.pluralize 
  end

  def self.column_names
    sql = <<-SQL
      pragma table_info('#{table_name}')
    SQL

    DB[:conn].results_as_hash = true
    table_info = DB[:conn].execute(sql)
    table_info.map { |column| column["name"] }
  end

  def table_name_for_insert
    self.class.table_name
  end

  def col_names_for_insert
    self.class.column_names.delete_if { |name| name == "id" }.join(', ')
  end

  def values_for_insert
    values = []

    self.class.column_names.each do |name|
      values << "'#{send(name)}'" unless send(name).nil?
    end

    values.join(', ')
  end

  def save
    sql = <<-SQL
      insert into #{table_name_for_insert} (#{col_names_for_insert})
      values (#{values_for_insert})
    SQL

    DB[:conn].execute(sql)

    sql = <<-SQL
      select last_insert_rowid() from #{table_name_for_insert}
    SQL

    @id = DB[:conn].execute(sql)[0][0]
  end

  def self.find_by_name(name)
    sql = <<-SQL
      select * from #{self.table_name}
      where name = '#{name}'
    SQL

    DB[:conn].execute(sql)
  end

  def self.find_by(attribute)
    sql = <<-SQL
      select * from #{self.table_name}
      where #{attribute.keys[0]} = '#{attribute.values[0].to_s}'
    SQL

    DB[:conn].execute(sql)
  end

end
