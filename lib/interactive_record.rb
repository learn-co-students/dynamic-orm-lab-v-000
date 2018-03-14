require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord


#-------------------------------------------------------------------------------------------
#macros / metas
def self.table_name
    self.to_s.downcase.pluralize
end

def self.column_names
    DB[:conn].results_as_hash = true
    sql = "pragma table_info('#{table_name}')"
    table_info = DB[:conn].execute(sql)
    
    column_names = []
    table_info.each {|column| column_names << column["name"]}
    column_names.compact
end


def initialize (arguments={})
    arguments.each {|key,value| send("#{key}=",value)}
end



#-------------------------------------------------------------------------------------------
#instance

def table_name_for_insert
    self.class.table_name
end

def col_names_for_insert
    self.class.column_names.delete_if {|column_name| column_name == "id"}.join(", ")
end

def values_for_insert
    values = []
    self.class.column_names.each{ |col_name| values << "'#{send(col_name)}'" unless send(col_name).nil?}
    values.join(", ")
     
     
end

def save
    sql = "INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})"
    DB[:conn].execute(sql)

    sql = "SELECT last_insert_rowid() from #{table_name_for_insert}"
    @id = DB[:conn].execute(sql)[0][0]
end




#-------------------------------------------------------------------------------------------
#class
def self.find_by(parameters)
    
    #set up first part of statement (paramters agnostic)
    sql = "SELECT * from #{self.table_name} WHERE "
    
    #translate parameter keys to column names & parameter values to search values

    #only do all this if there are multilple parameters (otherwise skip down; much simpler w 1 param)
    if parameters.length > 1
                            cur_parmeter = 1
                            parameters.each{|key,value| 
                                            #adds the column / value correctly (if int..)
                                            if value.is_a? Integer
                                            sql = sql + "#{key} = #{value}"
                                            else
                                            sql = sql + "#{key} = '#{value}'"
                                            end
                                            
                                            #adds "AND" if multiple conditions
                                            #increments param counter so I know where I am
                                            if cur_parameter < paremeters.length
                                               sql = sql + "AND "
                                               cur_parameter += 1
                                            end
                                            }
    #this is if you only have 1 param
    else                                        
          parameters.each{|key,value|
                           if value.is_a? Integer
                           sql = sql + "#{key} = #{value}"
                           else
                           sql = sql + "#{key} = '#{value}'"
                           end          
                          }
    #eol
    end

    #execute assembled statement
    DB[:conn].execute(sql)

#eom    
end


def self.find_by_name(name)
    sql = "SELECT * from #{self.table_name} WHERE name = '#{name}'"


DB[:conn].execute(sql)
end



#eoc  
end