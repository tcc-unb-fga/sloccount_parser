#!/usr/bin/ruby
require 'nokogiri'
require_relative 'database'

DATA_PATH=ENV['DATA_PATH']
WEAKN_OUTP = '/tmp/'

class Weakness


  def initialize
    @weakn_report = ''
    @project_name = []
    @weakness_list = []
  end

  attr_accessor :app_names, :weakness_list

  def collect_weakness
     begin
     sources = Dir.entries(DATA_PATH)
     sources.delete('.')
     sources.delete('..')
    rescue SystemCallError
      puts "Diretório #{DATA_PATH} não encontrado"
    end
     parse_xml_weakness sources
  end

  def extract_from_file file_name
      app_name_with_ext = file_name.to_s.split('_')
      begin
        self.app_names << app_name_with_ext[1].split('.')[0]
      rescue Exception
        puts "App name invalid"
      end
  end

  def parse_xml_weakness files
    weakness_xml_list = []
    files.each do |file|
      self.app_names = extract_from_file(file)
      @doc = Nokogiri::XML(File.open(DATA_PATH + file))
      count_weakness(@doc.xpath("//name"))
    end
  end

  def count_weakness weaknesses
    weaknesses.each do |weakness|
      if /cweid=/.match(weakness.to_s)
        self.weakness_list << weakness.to_s.scan(/\=\"[0-9]*"/).first.delete('=')
      end
    end
    puts self.weakness_list
  end
end

a = Weakness.new()
a.collect_weakness
