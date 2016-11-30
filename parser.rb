#!/usr/bin/ruby
require 'json'
require_relative 'database'

DATA_PATH=ENV['DATA_PATH']
SLOCC_OUTP = '/tmp/'

class Parser

  attr_accessor :sloc_report, :sloc_value, :language
  attr_accessor :n_files, :app, :db

  def initialize
    @sloc_report = ''
    @sloc_value = ''
    @language = ''
    @n_files = ''
    @app = ''
    @db = Database.new()
  end

  def call source, files
    if files
      `sloccount #{DATA_PATH}/#{source} > #{self.sloc_report}`
    else
      `sloccount --filecount #{DATA_PATH}/#{source} > #{self.sloc_report}`
    end
  end

  def json file
    File.open(file).each_with_index do |line, index|

      if /SLOC/.match(line)
        sloc_parse(line, index)
      end

      if /#Files/.match(line)
        line = IO.readlines(self.sloc_report)[index + 1]
        self.n_files = line_value(line, 0)
      end

      if /Totals grouped by language/.match(line)
        language_line = IO.readlines(self.sloc_report)[index + 1]
        language = line_value(language_line, ":",  0)
        self.language = language
      end
    end
    self.db.create_db()
    self.db.insert(self) if check_json
  end

  def check_json
    !self.n_files.empty? and !self.sloc_value.empty?
  end

  private

  def sloc_parse(line, index)
    begin
      line_tokens = line.split(" ")
      if line_tokens[0] == 'SLOC' and line_tokens[1] == 'Directory'
         self.sloc_value =  line_value((IO.readlines(self.sloc_report)[index + 1]), 0)
         # puts "SLOC VAlUE: #{self.sloc_value}"
      end
    rescue Exception
      puts 'SLOC value not found in this line'
    end
  end

  def line_value line, char=" ", pos
    line.split(char)[pos]
  end
end

def exec_sloccount sources
  sources.each do |source|
    parser = Parser.new()
    sources = list
    if Dir.exists?(DATA_PATH + '/' + source.to_s)
      parser.app = source.to_s
      parser.sloc_report = SLOCC_OUTP + '_' + source.to_s
      parser.call(source, true)
      parser.json(parser.sloc_report)
      parser.call(source, false)
      parser.json(parser.sloc_report)
    end
  end
end

def list
    begin
    sources = Dir.entries(DATA_PATH)
    sources.delete('.')
    sources.delete('..')
  rescue SystemCallError
    puts "Diretório #{DATA_PATH} não encontrado"
  end
    sources
end

sources = list
exec_sloccount(sources)
