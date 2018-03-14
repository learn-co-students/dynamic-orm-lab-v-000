require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord

  #this is our super class that will be inherited by other classes
  #the below method, takes the class, converts the class name to a string, downcases that, than pluralize (add s) to the string to create a method that yields the name of what a newly created table should be called based onthe name of the class
  def self.table_name
      self.to_s.downcase.pluralize
  end

  #this creates an array of sql column names of the table created in the environment.rb file in config
  def self.column_names
      DB[:conn].results_as_hash = true # we use the #results_as_hash method, available to use from the SQLite3-Ruby gem. This method says: when a SELECT statement is executed, don't return a database row as an array, return it as a hash with the column names as keys.

      sql = "pragma table_info('#{table_name}')"   #  This will return to us (thanks to our handy #results_as_hash method) an array of hashes describing the table itself that was created in our config/environment.rb file. Each hash will contain information about one column. pragma table info yield a lot of information
      table_info = DB[:conn].execute(sql) #execute sql and store it in a variable
      column_names=[]
      table_info.each do |row|
          column_names << row["name"]  #this works because row is yielding a hash, and we want to retuen the name
      end
      column_names.compact
  end

  #Here, we define our method to take in an argument of options, which defaults to an empty hash. We expect #new to be called with a hash, so when we refer to options inside the #initialize method, we expect to be operating on a hash.
  #We iterate over the options hash and use our fancy metaprogramming #send method to interpolate the name of each hash key as a method that we set equal to that key's value. As long as each property has a corresponding attr_accessor, this #initialize method will work.
  def initialize(options={})
    options.each do |property, value|
      self.send("#{property}=", value)
    end
  end
  #important to note that after setting up the initialize method setter method, within the CHILD CLASS we need to setup a CLASS Method to specifically setup the attributes.  This class method will work the initialize method to setup the attributes for the class and set them

  #    So, to access the table name we want to INSERT into from inside our #save method, we will use the following: (this will use the code written in the beginning)
  def table_name_for_insert
    self.class.table_name
  end
  def col_names_for_insert
    self.class.column_names.delete_if {|col| col == "id"}.join(", ")
    #  There's one problem though. When we INSERT a row into a database table for the first time, we don't INSERT the id attribute. In fact, our Ruby object has an id of nil before it is inserted into the table. The magic of our SQL database handles the creation of an ID for a given table row and then we will use that ID to assign a value to the original object's id attribute.
    #So, when we save our Ruby object, we should not include the id column name or insert a value for the id column. Therefore, we need to remove "id" from the array of column names returned from the method call above:
    #  Notice that the column names in the statement are comma separated. Our column names returned by the code above are in an array. Let's turn them into a comma separated list, contained in a string:
              #self.class.column_names.delete_if {|col| col == "id"}.join(", ")
  end
  #lets format the column names so that they can be used in an INSERT sql statement
  def values_for_insert
      values = []
      self.class.column_names.each do |col_name|
        values << "'#{send(col_name)}'" unless send(col_name).nil?
      end
      values.join(", ")

    #  Let's iterate over the column names stored in #column_names and use the #send method with each individual column name to invoke the method by that same name and capture the return value:
      #              values = []
        #            self.class.column_names.each do |col_name|
          #              values << "'#{send(col_name)}'" unless send(col_name).nil?
          #            end
    #  Here, we push the return value of invoking a method via the #send method, unless that value is #nil (as it would be for the id method before a record is saved, for instance).
    #  Notice that we are wrapping the return value in a string. That is because we are trying to craft #a string of SQL. Also notice that each individual value will be enclosed in single quotes, ' ', #inside that string. That is because the final SQL string will need to look like this:

    #            INSERT INTO songs (name, album)
    #            VALUES 'Hello', '25';
    #  SQL expects us to pass in each column value in single quotes.
    #  The above code, however, will result in a values array
    #            ["'the name of the song'", "'the album of the song'"]
    #  We need comma separated values for our SQL statement. Let's join this array into a string:
    #            values.join(", ")
  end

  def save
      sql = <<-SQL
            INSERT INTO #{table_name_for_insert}
            (#{col_names_for_insert}) VALUES (#{values_for_insert})
            SQL
      DB[:conn].execute(sql)
      #set the @id attribute using the database primary key id to our object after saving into the database
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  end

  def self.find_by_name(name)
    sql = <<-SQL
            SELECT *
            FROM #{self.table_name}
            WHERE name = ?
            SQL
    DB[:conn].execute(sql, name)
  end

  def self.find_by(attribute_hash)
    value = attribute_hash.values.first  #by narrowing down by values, to first, when we run .class we can see if it is a string or a Fixnum, if no .first was used when .class is used on that result you get array for both types
    formatted_value = value.class == Fixnum ? value : "'#{value}'"
    sql = <<-SQL
            SELECT *
            FROM #{self.table_name}
            WHERE #{attribute_hash.keys.first} = #{formatted_value}
          SQL
    DB[:conn].execute(sql)

  end

end
