require_relative "../config/environment.rb"
require 'active_support/inflector'

#SUPER CLASS - This file is where almost all of your ORM code will live.
#Once you set this up, you will share the methods in this class with the child class.


class InteractiveRecord
#takes the name of the class, referenced by the self keyword, turns it into a
#string with #to_s, downcases that string and then pluralizes it.
  def self.table_name
    self.to_s.downcase.pluralize
  end

#PRAGMA table_info(<table name>) will bring us an array of hashes describing the
#table itself. Each hash will contain information about one column.

#Here we write a SQL statement using the pragma keyword and the #table_name method
#(to access the name of the table we are querying). We iterate over the resulting
#array of hashes to collect just the name of each column. We call #compact on that
#just to be safe and get rid of any nil values that may end up in our collection.
  def self.column_names
    DB[:conn].results_as_hash = true

    sql = "pragma table_info('#{table_name}')"

    table_info = DB[:conn].execute(sql)
    column_names = []
    table_info.each do |row|
      column_names.push(row["name"])
    end
    column_names.compact
  end

#we define our method to take in an argument of options, which defaults to an empty
#hash. We expect #new to be called with a hash, so when we refer to options inside
#the #initialize method, we expect to be operating on a hash.

#We iterate over the options hash and use our fancy metaprogramming #send method to
#interpolate the name of each hash key as a method that we set equal to that key's
#value. As long as each property has a corresponding attr_accessor, this #initialize
#method will work.
  def initialize(options={})
  options.each do |property, value|
    self.send("#{property}=", value)
    end
  end

# to access the table name we want to INSERT into from inside our #save method
  def table_name_for_insert
    self.class.table_name
  end

#a comma separated list, contained in a string allows us to grab list of the
#column names of the table associated with any given class.

  def col_names_for_insert
    self.class.column_names.delete_if do |col|
    col == "id"
    end.join(", ")
  end

  def values_for_insert
  values = []
  self.class.column_names.each do |col_name|
    values << "'#{send(col_name)}'" unless send(col_name).nil?
    end
    values.join(", ")
  end

#saves the student to the database and sets the student's id
  def save
    sql = "INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})"

    DB[:conn].execute(sql)

    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  end

#dynamic and abstract because it does not reference the table name explicitly.
#Instead it uses the #table_name class method we built that will return the
#table name associated with any given class.
  def self.find_by_name(name)
    sql = <<-SQL
      SELECT *
      FROM #{self.table_name}
      WHERE name = "#{name}"
    SQL

    DB[:conn].execute(sql)
  end

#executes the SQL to find a row by the attribute passed into the method and
#accounts for when an attribute value is an integer
  def self.find_by(hash)
  value = hash.values.first
  integer = value.to_i
    if value.class == integer
      "'#{value}'"
    else
      value
    end

  sql = <<-SQL
    SELECT *
    FROM #{self.table_name}
    WHERE #{hash.keys.first} = "#{value}"
  SQL

  DB[:conn].execute(sql)
end

end#ofclass
