require_relative "../config/environment.rb"
require 'active_support/inflector'
require "pry"
class InteractiveRecord
  #gets the name of the table for an artibitrary class
  def self.table_name
    self.to_s.downcase.pluralize #converts self to a string and adds an s with pluralize (thanks, inflector)
  end

  def self.column_names
    #returns all results from SQL queries as hashes instead of arrays
    DB[:conn].results_as_hash=true

    #Pragma statements are unique to SQLite
    #This table_info statement gets a row about each table column (includes column title and data type, etc.)
    sql="pragma table_info('#{table_name}')"  #table name is passed here from the method above

    table_info=DB[:conn].execute(sql) #stores column information as a hash into table_info varaible
    column_names=[]
    table_info.each do |row|
      column_names<<row["name"]  #thanks to returning hashes, we can just ask for the column name for each column (stored here as a row)
    end
    column_names.compact #adding in compact, just incase there are nils or unnamed columns.
  end

  #Dynamic initialize method takes in a hash as options for initialization
  def initialize(options={})
    options.each do |property,value|    #for each key/value pair in the options hash passed in
      self.send("#{property}=", value)   #call self.PROPERTY=value to create 'setters' for each option (getters or attr_accessors assigned in the child class)
    end
  end

  #must be defined separately from table_name because it's an instance method.
  def table_name_for_insert
    self.class.table_name
  end

  #same deal here, the class has a column_names method, every instance will be able to access it then.
  def col_names_for_insert
    res=[]
    names=self.class.column_names #gets all the names as an array from class method
    names.each do |name|
      if name!="id"   #if the name isn't id
        res<<name     #dump it into the results, or shovel it rather...
      end
    end
    res.join(', ')     #return that ish as a comma-separated string
  end

  def values_for_insert
    values=[]
    cols=self.class.column_names
    cols.each do |attribute|
      if attribute!="id"
        val="'#{send(attribute)}'" unless send(attribute).nil? #Gotta wrap senc(attribute) in single quotes for SQL use later, so a string of strings can be created
        values<<val
      end
    end
    values.join(', ')
  end

  def save
    sql="INSERT INTO #{table_name_for_insert}(#{col_names_for_insert}) VALUES (#{values_for_insert})"
    DB[:conn].execute(sql)
    id_hash=DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}" )[0] #!forgot to flatten!!
    @id=id_hash["last_insert_rowid()"] #after it's flattened, you gotta get the value using the key
  end

  def self.find_by_name(name)
    sql="SELECT * from #{self.table_name} WHERE name = '#{name}'" #Gotta wrap these interpolations in single quotes!!
    DB[:conn].execute(sql)
  end

  def self.find_by(atr_hash)
    key=atr_hash.keys.first
    val=atr_hash[key]
    sql="SELECT * from #{self.table_name} WHERE #{key} = '#{val}'" # Wrap it!
    DB[:conn].execute(sql)
  end





end
