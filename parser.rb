#!/usr/bin/ruby
#

DATA_PATH=ENV['DATA_PATH']
SLOCC_OUTP = '/tmp/'

class Parser

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
  
  def run_sloccount sources
    sources.each do |source|
      if Dir.exists?(DATA_PATH + '/' + source.to_s)
         sloc_report = SLOCC_OUTP + '_' + source.to_s
        `sloccount #{DATA_PATH}/#{source} > #{sloc_report}`
        json(sloc_report)
      end
    end
  end

  def json file
    File.open(file).each do |line|
    end
  end
end

a = Parser.new()
sources = a.list
a.run_sloccount(sources)
