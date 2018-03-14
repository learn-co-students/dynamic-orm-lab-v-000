require_relative "../config/environment.rb"
# require 'active_support/inflector'
# possible deprecated dependency.  Instead of using #pluralize, just interpolate

class InteractiveRecord
  def self.table_name
    "#{self.to_s.downcase}s"
  end

  def self.column_names
    sql = "PRAGMA table_info(#{table_name})"
    table_info =  DB[:conn].execute(sql)
    column_names = []
    table_info.collect do |row|
      column_names << row["name"]
    end
    column_names.compact
  end

  def initialize(options={})
    options.each do |key, value|
      self.send("#{key}=", value)
    end
  end

  def table_name_for_insert
    self.class.table_name
  end

  def col_names_for_insert
    self.class.column_names[1..-1].join(", ")
  end

  def values_for_insert
    attributes = self.class.column_names[1..-1]
    values = []
    attributes.each do |attribute|
      values << "'#{self.send(attribute)}'"
    end
    values.join(", ")
  end

  def save
    #QUESTION 1: Is it still an abstract method if I am assuming that self.id is a method that exists?

    if !!self.id

      puts "Assigned already!"
      puts "Put an update method here!"
    else
      sql = "INSERT INTO #{self.class.table_name} (#{self.col_names_for_insert}) VALUES (#{self.values_for_insert})"
      DB[:conn].execute(sql)

      insert_id_hash = DB[:conn].execute("SELECT last_insert_rowid() FROM #{self.class.table_name}").first

      self.id = insert_id_hash["last_insert_rowid()"]
      self
    end
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM #{self.table_name} WHERE name = '#{name}'"
    result = DB[:conn].execute(sql)
  end

  def self.find_by(attribute_hash)
    #QUESTION 2: How do I account for several key/value pairs being passed in?
    # attr_key = nil
    # attribute_hash.each do |key, value|
    #   attr_key = key
    # end
    attribute_hash.values
    binding.pry

    sql = "SELECT * FROM #{self.table_name} WHERE #{attr_key} = '#{attribute_hash[attr_key]}'"
    DB[:conn].execute(sql)
  end
end
