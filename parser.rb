#!/usr/bin/ruby

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
    find_sloc_p_line = false
    find_sloc_line = false
    sloc_value = ''
    File.open(file).each do |line|
      # print line
      if /SLOC/.match(line) and !find_sloc_p_line
        find_sloc_p_line = true
        next
      end

      if find_sloc_p_line and !find_sloc_line
        sloc_value = line.split(" ")[0]
        puts "SLOC VALUE: #{sloc_value}"
        find_sloc_line = true
      end
    end

  end
end

a = Parser.new()
sources = a.list
a.run_sloccount(sources)
