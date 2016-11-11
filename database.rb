#!/usr/bin/ruby
require 'sqlite3'

class Database

  attr_accessor :db

  def initialize
    @db = SQLite3::Database.new "projects.db"
  end

  def create_db
    self.db.execute <<-SQL
      create table project (
          sloc int,
          n_files int,
          language varchar(30)
      );

      create table wekeness (
          sloc int,
          n_files int,
          language varchar(30)
      );
    SQL
  end

  def insert parser_obj
    self.db.execute("INSERT INTO project (sloc, n_files, language)
                           VALUES (?, ?, ?)", [parser_obj.sloc_value ,
                                               parser_obj.n_files,
                                               parser_obj.language])
  end
end
