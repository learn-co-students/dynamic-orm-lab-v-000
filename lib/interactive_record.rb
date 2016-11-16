require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord
   def self.table_name
      self.to_s.downcase+'s'
   end

   def self.column_names
    DB[:conn].results_as_hash = true
    r=[]
    DB[:conn].execute("pragma table_info('#{table_name}')").each do |c|
      r << c["name"]
    end
    r.compact
  end

   def initialize h={}
     h.each{|k,v| self.send("#{k}=",v)}
   end
   
   def table_name_for_insert
      self.class.table_name
   end
   
   def col_names_for_insert
      r=""
      self.class.column_names.each_with_index do |n,i| 
      if n!="id"
        if r=="" then r=n 
        else 
           r+=", "+n 
        end
      end
      end
      r
   end

   def self.find_by_name name
      DB[:conn].execute("SELECT * FROM #{table_name} WHERE name='#{name}'")
   end

   def self.find_by h
      DB[:conn].execute("SELECT * FROM #{table_name} WHERE #{h.keys[0]}='#{h.values[0]}'")
   end
   
   def values_for_insert
      r=[]
      self.class.column_names.each do |cn|
         d=send(cn)
         if d!=nil then r<<"'#{d}'" end
      end
      s=""
      r.each{|v| if s=="" then s=v else s+=", "+v end}
      s
   end

   def save
    sql = "INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})"
    DB[:conn].execute(sql)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  end

  
end